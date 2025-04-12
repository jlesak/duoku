//
//  PuzzleGenerator.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import Foundation

/// The PuzzleGenerator class is responsible for generating a new Sudoku puzzle and its solution.
/// This is a simplified wrapper around SeededPuzzleGenerator to maintain backward compatibility.
class PuzzleGenerator {
    /// Generates a new Sudoku puzzle along with its complete solution based on the provided difficulty level.
    ///
    /// - Parameter difficulty: The difficulty level that affects how many cells will be emptied.
    /// - Returns: A GameBoard object containing the puzzle and solution.
    static func generatePuzzle(for difficulty: DifficultyLevel) -> GameBoard {
        // Use the SeededPuzzleGenerator for better determinism and consistency
        return SeededPuzzleGenerator.generatePuzzle(for: difficulty)
    }
}
