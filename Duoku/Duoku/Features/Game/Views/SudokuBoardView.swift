//
//  SudokuBoardView.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import SwiftUI

/// A view representing the entire 9x9 Sudoku board.
struct SudokuBoardView: View {
    @ObservedObject var viewModel: SudokuViewModel
    
    var body: some View {
        GeometryReader { geo in
            let boardSize = min(geo.size.width, geo.size.height)
            let cellSize = boardSize / 9.0
            VStack(spacing: 0) {
                ForEach(0..<9, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<9, id: \.self) { col in
                            let cell = viewModel.gameManager.board[row][col]
                            SudokuCellView(cell: cell)
                                .frame(width: cellSize, height: cellSize)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.selectCell(row: row, col: col)
                                }
                        }
                    }
                }
            }
            // Constrain the board to a square of boardSize.
            .frame(width: boardSize, height: boardSize)
            // Overlay thick borders for the 3x3 subgrids.
            .overlay(
                GeometryReader { innerGeo in
                    let size = min(innerGeo.size.width, innerGeo.size.height)
                    let cellSize = size / 9.0
                    Path { path in
                        // Draw horizontal thick lines at the 3x3 subgrid boundaries.
                        for i in 0...3 {
                            let offset = CGFloat(i) * cellSize * 3
                            path.move(to: CGPoint(x: 0, y: offset))
                            path.addLine(to: CGPoint(x: size, y: offset))
                        }
                        // Draw vertical thick lines at the 3x3 subgrid boundaries.
                        for i in 0...3 {
                            let offset = CGFloat(i) * cellSize * 3
                            path.move(to: CGPoint(x: offset, y: 0))
                            path.addLine(to: CGPoint(x: offset, y: size))
                        }
                    }
                    .stroke(Color.black, lineWidth: 2)
                }
            )
        }
        .aspectRatio(1, contentMode: .fill)
    }
}

struct SudokuBoard_Previews: PreviewProvider {
    static var previews: some View {
        let generated = PuzzleGenerator.generatePuzzle(for: DifficultyLevel.easy)
        let gameManager = GameManager(puzzle: generated.puzzle, solution: generated.solution)
        let sudokuViewModel = SudokuViewModel(gameManager: gameManager)
        SudokuBoardView(viewModel: sudokuViewModel)
    }
}
