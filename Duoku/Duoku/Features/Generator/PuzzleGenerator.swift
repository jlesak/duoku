//
//  PuzzleGenerator.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import Foundation

/// The PuzzleGenerator class is responsible for generating a new Sudoku puzzle and its solution based on a selected difficulty level.
/// The generation process follows these steps:
/// 1. Generate a complete and valid Sudoku board using a backtracking algorithm.
/// 2. Remove numbers from the solved board based on the difficulty level while ensuring the resulting puzzle has a unique solution.

class PuzzleGenerator {
    /// The size of the Sudoku board (9x9).
    private static let boardSize: Int = 9
    /// The size of a subgrid (3x3).
    private static let subgridSize: Int = 3
    
    /// Generates a new Sudoku puzzle along with its complete solution based on the provided difficulty level.
    ///
    /// - Parameter difficulty: The difficulty level that affects how many cells will be emptied.
    /// - Returns: A tuple containing:
    ///   - puzzle: A 2D array of integers representing the puzzle board (0 indicates an empty cell).
    ///   - solution: A 2D array of integers representing the complete solved board.
    static func generatePuzzle(for difficulty: DifficultyLevel) -> (puzzle: [[Int]], solution: [[Int]]) {
        // Step 1: Generate a fully solved board.
        var solvedBoard = Array(repeating: Array(repeating: 0, count: boardSize), count: boardSize)
        guard fillBoard(&solvedBoard) else {
            fatalError("Failed to generate a complete Sudoku solution board.")
        }
        
        // Step 2: Create a puzzle by removing cells from the solved board based on the selected difficulty.
        var puzzleBoard = solvedBoard
        let cellsToRemove = numberOfCellsToRemove(for: difficulty)
        removeCells(&puzzleBoard, cellsToRemove: cellsToRemove)
        
        // Ensure the resulting puzzle has a unique solution.
        if !isUniquePuzzle(puzzleBoard) {
            // If the puzzle does not have a unique solution, regenerate it.
            return generatePuzzle(for: difficulty)
        }
        
        return (puzzle: puzzleBoard, solution: solvedBoard)
    }
    
    /// Fills the board completely using a backtracking algorithm.
    ///
    /// - Parameter board: A mutable 2D array representing the Sudoku board.
    /// - Returns: True if the board is successfully filled, false otherwise.
    private static func fillBoard(_ board: inout [[Int]]) -> Bool {
        guard let (row, col) = findEmptyCell(in: board) else {
            return true // The board is completely filled.
        }
        
        var numbers = Array(1...boardSize)
        numbers.shuffle() // Randomize numbers for variation.
        
        for number in numbers {
            if isValid(board, number: number, row: row, col: col) {
                board[row][col] = number
                if fillBoard(&board) {
                    return true
                }
                board[row][col] = 0
            }
        }
        
        return false
    }
    
    /// Finds the first empty cell (i.e. a cell with value 0) in the board.
    ///
    /// - Parameter board: The Sudoku board.
    /// - Returns: A tuple (row, col) of the empty cell, or nil if the board is full.
    private static func findEmptyCell(in board: [[Int]]) -> (Int, Int)? {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                if board[row][col] == 0 {
                    return (row, col)
                }
            }
        }
        return nil
    }
    
    /// Determines whether placing a given number in a specific cell is valid according to Sudoku rules.
    ///
    /// - Parameters:
    ///   - board: The Sudoku board.
    ///   - number: The number to place.
    ///   - row: The row index.
    ///   - col: The column index.
    /// - Returns: True if the placement is valid; otherwise, false.
    private static func isValid(_ board: [[Int]], number: Int, row: Int, col: Int) -> Bool {
        // Check the row.
        if board[row].contains(number) {
            return false
        }
        // Check the column.
        for i in 0..<boardSize {
            if board[i][col] == number {
                return false
            }
        }
        // Check the 3x3 subgrid.
        let startRow = (row / subgridSize) * subgridSize
        let startCol = (col / subgridSize) * subgridSize
        for i in 0..<subgridSize {
            for j in 0..<subgridSize {
                if board[startRow + i][startCol + j] == number {
                    return false
                }
            }
        }
        return true
    }
    
    /// Determines the number of cells to remove based on the selected difficulty level.
    ///
    /// - Parameter difficulty: The selected difficulty level.
    /// - Returns: The number of cells to remove from the fully solved board.
    private static func numberOfCellsToRemove(for difficulty: DifficultyLevel) -> Int {
        switch difficulty {
        case .easy:
            return 30  // About 51 prefilled cells.
        case .medium:
            return 40  // About 41 prefilled cells.
        case .hard:
            return 50  // About 31 prefilled cells.
        case .expert:
            return 55  // About 26 prefilled cells.
        case .evil:
            return 60  // About 21 prefilled cells.
        }
    }
    
    /// Removes a specified number of cells from the board randomly, ensuring the puzzle remains uniquely solvable.
    ///
    /// - Parameters:
    ///   - board: The Sudoku board to modify (with a complete solution).
    ///   - cellsToRemove: The number of cells to remove.
    private static func removeCells(_ board: inout [[Int]], cellsToRemove: Int) {
        var removedCells = 0
        var cellPositions = [(row: Int, col: Int)]()
        
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                cellPositions.append((row, col))
            }
        }
        cellPositions.shuffle()
        
        for position in cellPositions {
            if removedCells >= cellsToRemove {
                break
            }
            let backupValue = board[position.row][position.col]
            board[position.row][position.col] = 0
            
            // Check if the board still has a unique solution.
            if !isUniquePuzzle(board) {
                board[position.row][position.col] = backupValue
            } else {
                removedCells += 1
            }
        }
    }
    
    /// Determines if the given puzzle board has a unique solution.
    /// The method uses a backtracking solver that counts solutions, stopping early if more than one is found.
    ///
    /// - Parameter board: The puzzle board with empty cells (represented as 0).
    /// - Returns: True if the puzzle has a unique solution; otherwise, false.
    private static func isUniquePuzzle(_ board: [[Int]]) -> Bool {
        var solutionCounter = 0
        var boardCopy = board
        
        /// Recursive helper function that counts solutions.
        func countSolutions(_ board: inout [[Int]]) {
            guard let (row, col) = findEmptyCell(in: board) else {
                solutionCounter += 1
                return
            }
            
            for number in 1...boardSize {
                if isValid(board, number: number, row: row, col: col) {
                    board[row][col] = number
                    countSolutions(&board)
                    if solutionCounter > 1 {
                        return
                    }
                    board[row][col] = 0
                }
            }
        }
        
        countSolutions(&boardCopy)
        return solutionCounter == 1
    }
}
