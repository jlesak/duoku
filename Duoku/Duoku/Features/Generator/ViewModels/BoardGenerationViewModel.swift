//
//  BoardGenerationViewModel.swift
//  Duoku
//
//  Created by Jan Lesák on 11.04.2025.
//


import SwiftUI

final class BoardGenerationViewModel: ObservableObject {
    @Published var generationProgress: Double = 0.0
    @Published var isGenerationComplete: Bool = false
    
    private let totalBoards: Int
    private let difficulty: DifficultyLevel
    private var boards: [GameBoard] = []
    
    // A fixed seed or a deterministic approach can be used to assign repeatable IDs.
    // For instance, use sequential numbering.
    init(totalBoards: Int = 10, difficulty: DifficultyLevel = .medium) {
        self.totalBoards = totalBoards
        self.difficulty = difficulty
    }
    
    // Generates all boards asynchronously.
    func generateBoards() async {
        // For each board, call your provided generation method on a background thread.
        for i in 0..<totalBoards {
            // Use an asynchronous task to avoid blocking the main thread.
            let boardData = await generateSingleBoard()
            
            // Create a deterministic ID. (For example "BOARD-0001", etc.)
            let boardID = String(format: "%04d", i)
            
            let gameBoard = GameBoard(
                id: boardID,
                puzzle: boardData.puzzle,
                solution: boardData.solution,
                difficulty: boardData.difficulty,
                seed: boardData.seed)
            boards.append(gameBoard)
            
            // Update progress on the main thread.
            await MainActor.run {
                self.generationProgress = Double(i + 1) / Double(self.totalBoards)
            }
        }
        
        // When finished, persist the board data.
        do {
            try GameBoardStore.shared.save(boards: boards)
            await MainActor.run {
                self.isGenerationComplete = true
            }
        } catch {
            // Handle error appropriately – you might want to show an alert or retry.
            print("Error saving boards: \(error)")
        }
    }
    
    // Wraps the synchronous generation method in an asynchronous context.
    private func generateSingleBoard() async -> GameBoard {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = PuzzleGenerator.generatePuzzle(for: self.difficulty)
                continuation.resume(returning: result)
            }
        }
    }
    
    // Retrieve a board by id if needed later in the game (for multiplayer lookup).
    func board(for id: String) -> GameBoard? {
        return boards.first { $0.id == id }
    }
}
