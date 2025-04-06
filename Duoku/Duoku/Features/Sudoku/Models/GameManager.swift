//
//  GameManager.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import Foundation

/// Třída reprezentující jednu buňku sudoku. Nyní je ObservableObject a obsahuje stav zvýraznění.


/// Represents a single cell in the Sudoku board.
/// Conforms to Identifiable so SwiftUI can uniquely identify each cell.
class SudokuCell: Identifiable, ObservableObject {
    let id = UUID() // Unique identifier for SwiftUI
    let row: Int // Row index (0-8)
    let col: Int // Column index (0-8)
    @Published var value: Int // Current digit (0 if empty)
    let isPreFilled: Bool // True if cell is part of the original puzzle and cannot be changed
    @Published var isHighlighted: Bool = false
    @Published var isSelected: Bool = false
    
    init(row: Int, col: Int, value: Int, isPreFilled: Bool) {
        self.row = row
        self.col = col
        self.value = value
        self.isPreFilled = isPreFilled
    }
}

/// Manages the game logic and state of the Sudoku board.
class GameManager {
    
    // A 9x9 grid of Sudoku cells.
    var board: [[SudokuCell]] = []
    // Count of mistakes made by the user.
    var mistakesCount: Int = 0
    // Maximum mistakes allowed before game over.
    let maxMistakes: Int = 3
    
    var rows: [Int: [SudokuCell]] = [:]
    var columns: [Int: [SudokuCell]] = [:]
    var squares: [Int: [SudokuCell]] = [:]
    private var highlightedCells: [UUID: SudokuCell] = [:]
    
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
        // Kontrola řádku.
        for c in 0..<9 {
            if board[row][c].value == value { return false }
        }
        // Kontrola sloupce.
        for r in 0..<9 {
            if board[r][col].value == value { return false }
        }
        // Kontrola 3×3 čtverce.
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
    func placeValue(_ value: Int, atRow row: Int, col: Int) -> Bool {
        let cell = board[row][col]
        // Nelze měnit předvyplněné buňky.
        guard !cell.isPreFilled else { return false }
        
        if canPlaceValue(value, atRow: row, col: col) {
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
        cell.isHighlighted = isHighlighted
        
        if isHighlighted
        {
            highlightedCells[cell.id] = cell
        }
        else
        {
            highlightedCells.removeValue(forKey: cell.id)
        }
    }
    
    func clearHighlights()
    {
        for cell in highlightedCells {
            cell.value.isHighlighted = false
        }
        
        highlightedCells.removeAll()
    }
}
