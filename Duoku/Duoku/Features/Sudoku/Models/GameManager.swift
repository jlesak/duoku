//
//  GameManager.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import Foundation

/// Manages the game logic and state of the Sudoku board.
class GameManager {
    // A 9x9 grid of Sudoku cells.
    var board: [[SudokuCell]] = []
    // Count of mistakes made by the user.
    var mistakesCount: Int = 0
    // Maximum mistakes allowed before game over.
    let maxMistakes: Int = 100
    
    var rows: [Int: [SudokuCell]] = [:]
    var columns: [Int: [SudokuCell]] = [:]
    var squares: [Int: [SudokuCell]] = [:]
    private var highlightedCells: [SudokuCell] = []
    
    // Initializes the board using a static puzzle. TODO: Generate new puzzle or get it from pre-generated
    init() {
        // A static puzzle layout.
        let puzzle: [[Int]] = [
            [5,1,0, 8,6,0, 0,0,0],
            [0,0,0, 0,0,0, 8,0,0],
            [0,8,6, 0,0,0, 0,0,0],
            
            [4,9,0, 0,0,0, 1,0,0],
            [0,7,0, 2,0,8, 0,9,4],
            [1,0,0, 0,0,0, 0,3,0],
            
            [0,0,0, 7,2,9, 0,0,8],
            [7,0,2, 0,0,4, 9,0,3],
            [0,0,9, 5,0,0, 0,4,0]
        ]
        
        // Create the board by mapping over rows and columns.
        board = (0..<9).map { row in
            (0..<9).map { col in
                let val = puzzle[row][col]
                return SudokuCell(row: row, col: col, value: val, isPreFilled: val != 0)
            }
        }
        
        // Dictionaries fill
        for row in 0..<9 {
            for col in 0..<9 {
                let cell = board[row][col]
                rows[row, default: []].append(cell)
                columns[col, default: []].append(cell)
                let squareIndex = (row / 3) * 3 + (col / 3)
                squares[squareIndex, default: []].append(cell)
            }
        }
    }
    
    /// Checks whether a given digit can be placed in the specified cell.
    /// - Parameters:
    ///   - value: The digit to place.
    ///   - row: The row index.
    ///   - col: The column index.
    /// - Returns: True if the move is valid, false otherwise.
    func canPlaceValue(_ value: Int, atRow row: Int, col: Int) -> Bool {
        // Check row
        for c in 0..<9 {
            if board[row][c].value == value { return false }
        }
        // Check column
        for r in 0..<9 {
            if board[r][col].value == value { return false }
        }
        // Check 3x3 square
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        for r in boxRow..<boxRow+3 {
            for c in boxCol..<boxCol+3 {
                if board[r][c].value == value { return false }
            }
        }
        return true
    }
    
    /// Attempts to place a digit in the board.
    /// - Parameters:
    ///   - value: The digit to place.
    ///   - row: The row index.
    ///   - col: The column index.
    /// - Returns: True if the placement is valid; otherwise, false.
    func placeValue(_ value: Int, cell: SudokuCell) -> Bool {
        // Do not change pre-filled cells.
        guard !cell.isPreFilled else { return false }
        
        if canPlaceValue(value, atRow: cell.row, col: cell.col) {
            cell.value = value
            return true
        } else {
            mistakesCount += 1
            return false
        }
    }
    
    /// Clears the value of a cell (if it is not pre-filled).
    /// - Parameters:
    ///   - row: The row index.
    ///   - col: The column index.
    func clearValue(atRow row: Int, col: Int) {
        let cell = board[row][col]
        guard !cell.isPreFilled else { return }
        cell.value = 0
    }
    
    func setHighlight(_ cell: SudokuCell, isHighlighted: Bool)
    {
        if cell.isHighlighted == isHighlighted { return }
        
        cell.isHighlighted = isHighlighted
        
        if isHighlighted {
            highlightedCells.append(cell)
            return
        }
        
        // remove from highlighted if exists
        if let index = highlightedCells.firstIndex(of: cell) {
            highlightedCells.remove(at: index)
        }
    }
    
    func clearHighlights()
    {
        for cell in highlightedCells {
            cell.isHighlighted = false
        }
        
        highlightedCells.removeAll()
    }
}
