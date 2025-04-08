//
//  SudokuCell.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import Foundation

/// Represents a single cell in the Sudoku board.
/// Conforms to Identifiable so SwiftUI can uniquely identify each cell.
class SudokuCell: Identifiable, ObservableObject, Equatable {
    let id = UUID() // Unique identifier for SwiftUI
    let row: Int // Row index (0-8)
    let col: Int // Column index (0-8)
    @Published var value: Int // Current digit (0 if empty)
    let isPreFilled: Bool // True if cell is part of the original puzzle and cannot be changed
    @Published var isHighlighted: Bool = false
    @Published var isSelected: Bool = false
    @Published var isNumberSelected: Bool = false
    @Published var notes: Set<Int> = []
    
    init(row: Int, col: Int, value: Int, isPreFilled: Bool) {
        self.row = row
        self.col = col
        self.value = value
        self.isPreFilled = isPreFilled
    }
    
    static func == (lhs: SudokuCell, rhs: SudokuCell) -> Bool {
        lhs.id == rhs.id
    }
}
