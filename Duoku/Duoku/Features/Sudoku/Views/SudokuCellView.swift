//
//  SudokuCellView.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import SwiftUI

/// A view representing a single Sudoku cell.
struct SudokuCellView: View {
    @ObservedObject var cell: SudokuCell         // The cell data to display.
    
    var body: some View {
        ZStack {
            // Set background color if the cell or a row/column/square is selected
            Rectangle()
                .fill(cell.isSelected ? Color.blue.opacity(0.3)
                      : cell.isHighlighted ? Color.gray.opacity(0.2)
                      : Color.white)
                .border(Color.gray, width: 0.5)
            
            // Show cell value if it's not '0' which means empty
            Text(cell.value == 0 ? "" : "\(cell.value)")
                .font(cell.isPreFilled ? .headline : .subheadline)
                .foregroundColor(cell.isPreFilled ? .black : .blue)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
