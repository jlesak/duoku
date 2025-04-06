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
            
            // If a main digit is set, display it.
            if cell.value != 0 {
                Text("\(cell.value)")
                    .font(.system(size: 25))
                    .foregroundColor(cell.isPreFilled ? .black : .blue)
            }
            // If the cell is empty and has notes, display them in a 3x3 grid.
            else if !cell.notes.isEmpty {
                VStack(spacing: 1) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 1) {
                            ForEach(1...3, id: \.self) { col in
                                let noteDigit = row * 3 + col
                                // Always display the note digit with the same font and size,
                                // but use opacity(0) when the note is not present.
                                Text("\(noteDigit)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                    .opacity(cell.notes.contains(noteDigit) ? 1 : 0)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
                // Remove extra padding and force the notes grid to fill the available space.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
