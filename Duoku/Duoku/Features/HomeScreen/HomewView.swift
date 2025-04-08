import SwiftUI

struct HomeView: View {
    @State private var currentGameViewModel: SudokuViewModel? = nil
    @State private var navigateToGame: Bool = false
    @State private var bestScore: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                // App Title
                Text("Duoku")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Best Score Display
                Text("Best Score: \(bestScore)")
                    .font(.headline)
                
                Spacer()

                // "Continue Game" button (only shown if a game exists)
                if let _ = currentGameViewModel {
                    Button(action: {
                        navigateToGame = true
                    }) {
                        Text("Continue Game")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                
                // New Game Section: Always visible with difficulty selection buttons.
                VStack(spacing: 16) {
                    Text("New Game")
                        .font(.title)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ForEach(DifficultyLevel.allCases, id: \.self) { level in
                        Button(action: {
                            // Start a new game with the selected difficulty.
                            let generated = PuzzleGenerator.generatePuzzle(for: level)
                            let newGameManager = GameManager(puzzle: generated.puzzle, solution: generated.solution)
                            let newViewModel = SudokuViewModel(gameManager: newGameManager)
                            currentGameViewModel = newViewModel
                            navigateToGame = true
                        }) {
                            Text(level.rawValue)
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $navigateToGame) {
                if let viewModel = currentGameViewModel {
                    SudokuView(viewModel: viewModel)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
