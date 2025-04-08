//
//  SudokuView.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import SwiftUI

/// The main Sudoku game view.
struct SudokuView: View {
    @StateObject var viewModel: SudokuViewModel
    
    init(viewModel: SudokuViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Top panel: elapsed time and mistakes count.
            HStack {
                Text("Time: \(viewModel.formattedTime)")
                Spacer()
                Text("Mistakes: \(viewModel.gameManager.mistakesCount)/\(viewModel.gameManager.maxMistakes)")
            }
            .padding(.horizontal)
            
            // Additional info such as Score and Difficulty.
            HStack {
                Text("Score: 0")
                Spacer()
                Text("Difficulty: Easy")
            }
            .padding(.horizontal)
            
            // The Sudoku board view.
            SudokuBoardView(viewModel: viewModel)
                .scaledToFit()
            
            // Control buttons view.
            ControlButtonsView(viewModel: viewModel)
            
            // Digit buttons view.
            DigitButtonsView(viewModel: viewModel)
            
            Spacer()
        }
        .padding()
        .onAppear {
            // Start the game timer when the view appears.
            viewModel.startTimer()
        }
        // Display a Game Over alert if maximum mistakes are reached.
        .alert(isPresented: .constant(viewModel.isGameOver())) {
            Alert(title: Text("Game Over"),
                  message: Text("You've reached the maximum number of mistakes!"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
#if DEBUG
    struct SudokuView_Previews: PreviewProvider {
        static var previews: some View {
            // For preview purposes, generate a puzzle with an "easy" difficulty.
            let generated = PuzzleGenerator.generatePuzzle(for: .easy)
            let gameManager = GameManager(puzzle: generated.puzzle, solution: generated.solution)
            let viewModel = SudokuViewModel(gameManager: gameManager)
            return SudokuView(viewModel: viewModel)
        }
    }
#endif
}
