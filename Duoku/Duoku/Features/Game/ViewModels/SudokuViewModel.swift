//
//  SudokuViewModel.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import Foundation
import Combine

/// The ViewModel ties the game logic to the SwiftUI views.
/// It is marked as ObservableObject so that changes trigger UI updates.
class SudokuViewModel: ObservableObject {
    @Published var gameManager: GameManager

    // Currently selected cell (if any).
    //@Published var selectedCell: (row: Int, col: Int)? = nil
    @Published var selectedCell: SudokuCell? = nil

    // Timer-related property to track elapsed seconds.
    @Published var secondsElapsed: Int = 0
    var timer: Timer?
    
    // Flag indicating if the Notes mode is active.
    @Published var isNotesMode: Bool = false
    
    // A simple stack to track moves for undo functionality.
    private var movesStack: [(row: Int, col: Int, oldValue: Int, newValue: Int)] = []

    /// Initializes the ViewModel with a specific game.
    /// - Parameter gameManager: The GameManager instance for the current game.
    init(gameManager: GameManager) {
        self.gameManager = gameManager
    }
    
    /// Starts the game timer.
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.secondsElapsed += 1
        }
    }
    
    /// Stops the game timer.
    func stopTimer() {
        timer?.invalidate()
    }
    
    func selectCell(row: Int, col: Int) {
        if (selectedCell != nil) {
            selectedCell!.isSelected = false
        }
        
        selectedCell = gameManager.board[row][col]
        selectedCell!.isSelected = true
        
        updateHighlighting()
    }
    
    private func updateHighlighting() {
        gameManager.clearHighlights()

        if (selectedCell == nil) { return }
        
        // Highlight same number cells
        gameManager.setNumberSelected(selectedCell!.value)
        
        // TODO: Highlight the notes numbers of the same number

        // Highlight row
        if let rowCells = gameManager.rows[selectedCell!.row] {
            for cell in rowCells {
                gameManager.setHighlight(cell, isHighlighted: true)
            }
        }
        // Highlight column
        if let colCells = gameManager.columns[selectedCell!.col] {
            for cell in colCells {
                gameManager.setHighlight(cell, isHighlighted: true)
            }
        }
        // highlight square
        let squareIndex = (selectedCell!.row / 3) * 3 + (selectedCell!.col / 3)
        if let squareCells = gameManager.squares[squareIndex] {
            for cell in squareCells {
                gameManager.setHighlight(cell, isHighlighted: true)
            }
        }
    }
    
    /// Places a digit in the selected cell.
    /// If notes mode is enabled, the digit is toggled in the cell’s notes (only if no main digit is present).
    /// If notes mode is disabled, the main digit is inserted and any existing notes are cleared.
    /// - Parameter digit: The digit to place.
    func placeDigit(_ digit: Int) {
        guard selectedCell != nil else { return }
        // Only allow changes for non pre-filled cells.
        guard !selectedCell!.isPreFilled else { return }
        
        if isNotesMode {
            // Only allow notes if there is no main digit.
            guard selectedCell!.value == 0 else { return }
            if selectedCell!.notes.contains(digit) {
                selectedCell!.notes.remove(digit)
            } else {
                selectedCell!.notes.insert(digit)
            }
        } else {
            let oldValue = selectedCell!.value
            let success = gameManager.placeValue(digit, cell: selectedCell!)
            if success {
                // Clear any existing notes in the cell.
                selectedCell!.notes.removeAll()
                
                // TODO: remove the digit from notes in the same row, column, and square
                updateHighlighting()
                movesStack.append((row: selectedCell!.row, col: selectedCell!.col, oldValue: oldValue, newValue: digit))
            }
        }
    }
    
    /// Undoes the last move made by the user.
    func undo() {
        guard let lastMove = movesStack.popLast() else { return }
        gameManager.board[lastMove.row][lastMove.col].value = lastMove.oldValue
    }

    func erase() {
        guard let cell = selectedCell else { return }
        let currentCell = gameManager.board[cell.row][cell.col]
        let oldValue = currentCell.value
        gameManager.clearValue(atRow: cell.row, col: cell.col)
        movesStack.append((row: cell.row, col: cell.col, oldValue: oldValue, newValue: 0))
    }

    func isGameOver() -> Bool {
        return gameManager.mistakesCount >= gameManager.maxMistakes
    }

    var formattedTime: String {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
