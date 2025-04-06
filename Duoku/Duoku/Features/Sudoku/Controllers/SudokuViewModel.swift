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
    
    // Instance of GameManager which contains the core game logic.
    @Published var gameManager = GameManager()
    
    // Currently selected cell (if any).
    @Published var selectedCell: (row: Int, col: Int)? = nil

    // Timer-related property to track elapsed seconds.
    @Published var secondsElapsed: Int = 0
    var timer: Timer?
    
    // Flag indicating if the Notes mode is active.
    @Published var isNotesMode: Bool = false
    
    // A simple stack to track moves for undo functionality.
    private var movesStack: [(row: Int, col: Int, oldValue: Int, newValue: Int)] = []
    
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
        if (selectedCell != nil)
        {
            gameManager.board[selectedCell!.row][selectedCell!.col].isSelected = false
        }
        
        selectedCell = (row, col)
        gameManager.board[row][col].isSelected = true
        updateHighlighting()
    }
    
    private func updateHighlighting() {
        // Zrušení zvýraznění u všech buněk.
        gameManager.clearHighlights()
        
        guard let selected = selectedCell else { return }
        gameManager.board[selected.row][selected.col].isSelected = true
        
        // Zvýraznění řádku.
        if let rowCells = gameManager.rows[selected.row] {
            for cell in rowCells {
                gameManager.setHighlight(cell, isHighlighted: true)
            }
        }
        // Zvýraznění sloupce.
        if let colCells = gameManager.columns[selected.col] {
            for cell in colCells {
                gameManager.setHighlight(cell, isHighlighted: true)
            }
        }
        // Výpočet indexu čtverce a zvýraznění.
        let squareIndex = (selected.row / 3) * 3 + (selected.col / 3)
        if let squareCells = gameManager.squares[squareIndex] {
            for cell in squareCells {
                gameManager.setHighlight(cell, isHighlighted: true)
            }
        }
    }
    
    /// Places a digit in the selected cell.
    /// - Parameter digit: The digit to place.
    func placeDigit(_ digit: Int) {
        guard let cell = selectedCell else { return }
            let currentCell = gameManager.board[cell.row][cell.col]
            let oldValue = currentCell.value
            
            let success = gameManager.placeValue(digit, atRow: cell.row, col: cell.col)
            
            if success {
                movesStack.append((row: cell.row, col: cell.col, oldValue: oldValue, newValue: digit))
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
