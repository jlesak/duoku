import SwiftUI
import Combine

struct HomeView: View {
    @State private var currentGameViewModel: SudokuViewModel? = nil
    @State private var navigateToGame: Bool = false
    @State private var bestScore: Int = 0
    @State private var storedBoards: [GameBoard] = []
    @State private var isLoading: Bool = false
    @State private var showingBoardIDInput = false
    @State private var boardIDInput = ""
    @State private var generationProgress: Double = 0.0
    @State private var isGeneratingBoards: Bool = false
    @State private var errorMessage: String = ""
    @State private var showingError: Bool = false
    
    // For managing subscription to progress updates
    @State private var progressCancellable: AnyCancellable?
    
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
                
                // Open Game by ID button
                Button(action: {
                    showingBoardIDInput = true
                }) {
                    Text("Open Game by ID")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading ? Color.gray : Color.green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(isLoading)
                
                // New Game Section: Always visible with difficulty selection buttons.
                VStack(spacing: 16) {
                    Text("New Game")
                        .font(.title)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ForEach(DifficultyLevel.allCases, id: \.self) { level in
                        Button(action: {
                            startNewGame(with: level)
                        }) {
                            Text(level.rawValue)
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isLoading ? Color.gray : Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .disabled(isLoading)
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
            .overlay {
                if isLoading {
                    ZStack {
                        // Dim the background
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        
                        if isGeneratingBoards {
                            // Show the progress overlay
                            BoardGenerationOverlay(progress: generationProgress)
                        } else {
                            // Show regular loading spinner
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray)
                                        .shadow(radius: 2)
                                )
                        }
                    }
                }
            }
            .sheet(isPresented: $showingBoardIDInput) {
                BoardIDInputView(isPresented: $showingBoardIDInput, onSubmit: startGameWithBoardID)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            loadStoredBoards()
        }
        .onDisappear {
            // Cancel subscription when view disappears
            progressCancellable?.cancel()
        }
    }
    
    private func loadStoredBoards() {
        Task {
            do {
                isLoading = true
                
                // Subscribe to both progress updates and generation status from GameBoardStore
                progressCancellable = Publishers.CombineLatest(
                    GameBoardStore.shared.progressPublisher,
                    GameBoardStore.shared.generatingPublisher
                )
                .receive(on: RunLoop.main)
                .sink { (progress, isGenerating) in
                    self.generationProgress = progress
                    self.isGeneratingBoards = isGenerating
                }
                
                // Load boards from the GameBoardStore
                // The GameBoardStore will automatically generate a standard set if none exist
                let boards = try GameBoardStore.shared.load()
                
                await MainActor.run {
                    self.storedBoards = boards
                    isLoading = false
                }
            } catch {
                print("Error loading boards: \(error)")
                await MainActor.run {
                    isLoading = false
                    isGeneratingBoards = false
                }
            }
        }
    }
    
    private func startNewGame(with difficulty: DifficultyLevel) {
        isLoading = true
        
        Task {
            do {
                // Get a random board for the selected difficulty
                guard let gameBoard = try GameBoardStore.shared.getRandomBoard(for: difficulty) else {
                    throw NSError(domain: "DuokuError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No boards available for difficulty \(difficulty.rawValue)"])
                }
                
                await MainActor.run {
                    let newGameManager = GameManager(gameBoard: gameBoard)
                    let newViewModel = SudokuViewModel(gameManager: newGameManager)
                    currentGameViewModel = newViewModel
                    isLoading = false
                    navigateToGame = true
                }
            } catch {
                print("Error starting new game: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func startGameWithBoardID(_ boardID: String) {
        isLoading = true
        
        Task {
            do {
                // Try to find the board with the given ID in storage
                if let storedBoard = try GameBoardStore.shared.findBoard(withID: boardID) {
                    // Use the stored board if found
                    await MainActor.run {
                        let newGameManager = GameManager(gameBoard: storedBoard)
                        let newViewModel = SudokuViewModel(gameManager: newGameManager)
                        currentGameViewModel = newViewModel
                        isLoading = false
                        navigateToGame = true
                    }
                } else {
                    // Check if the ID is a valid numeric seed
                    if let _ = Int(boardID) {
                        // If it's a numeric ID, use it directly as a seed
                        let board = SeededPuzzleGenerator.generatePuzzle(for: .medium, seed: boardID)
                        
                        // Save the board for future use
                        var boards = try GameBoardStore.shared.load()
                        boards.append(board)
                        try GameBoardStore.shared.save(boards: boards)
                        
                        await MainActor.run {
                            let newGameManager = GameManager(gameBoard: board)
                            let newViewModel = SudokuViewModel(gameManager: newGameManager)
                            currentGameViewModel = newViewModel
                            isLoading = false
                            navigateToGame = true
                        }
                    } else {
                        await MainActor.run {
                            errorMessage = "Invalid board ID. Please enter a numeric ID."
                            showingError = true
                            isLoading = false
                        }
                    }
                }
            } catch {
                print("Error starting game with ID: \(error)")
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isLoading = false
                }
            }
        }
    }
}

struct BoardIDInputView: View {
    @Binding var isPresented: Bool
    @State private var boardID = ""
    var onSubmit: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter Board ID")
                    .font(.headline)
                    .padding(.top)
                
                Text("Please enter a numeric board ID")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Board ID", text: $boardID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                
                Button("Start Game") {
                    if !boardID.isEmpty {
                        onSubmit(boardID)
                        isPresented = false
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(boardID.isEmpty ? Color.gray : Color.green)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(boardID.isEmpty || Int(boardID) == nil)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            })
        }
    }
}

// New view to show board generation progress
struct BoardGenerationOverlay: View {
    let progress: Double
    
    private var totalBoardCount: Int {
        // 10 boards per difficulty level * 4 difficulty levels
        return 40
    }
    
    private var completedBoardCount: Int {
        return Int(progress * Double(totalBoardCount))
    }
    
    private var percentageText: String {
        if progress < 1.0 {
            // Show one decimal place when not complete
            return String(format: "%.1f%%", progress * 100)
        } else {
            return "100%"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Generating Game Boards")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Detailed information about progress
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Completed:")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("\(completedBoardCount) of \(totalBoardCount) boards")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 8)
                    .tint(.blue)
                
                HStack {
                    Spacer()
                    Text(percentageText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 250)
            
            if progress < 1.0 {
                Text("Please wait while boards are generated...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            } else {
                Text("Completed!")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.9))
                .shadow(radius: 6)
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
