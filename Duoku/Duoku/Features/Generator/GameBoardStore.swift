//
//  GameBoardStore.swift
//  Duoku
//
//  Created by Jan Lesák on 11.04.2025.
//

import Foundation
import Combine

final class GameBoardStore {
    static let shared = GameBoardStore()
    
    private let fileName = "PreGeneratedGameBoardsV3.json"
    private let boardsPerDifficulty = 10 // Generate 10 boards per difficulty level
    
    // Progress tracking
    private let progressSubject = CurrentValueSubject<Double, Never>(0.0)
    var progressPublisher: AnyPublisher<Double, Never> {
        progressSubject.eraseToAnyPublisher()
    }
    
    // Generation status tracking
    private let generatingSubject = CurrentValueSubject<Bool, Never>(false)
    var generatingPublisher: AnyPublisher<Bool, Never> {
        generatingSubject.eraseToAnyPublisher()
    }
    
    // Cache for loaded boards to improve performance
    private var cachedBoards: [GameBoard]?
    
    // Returns the file URL where the boards will be stored.
    private var fileURL: URL? {
        let fm = FileManager.default
        guard let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documents.appendingPathComponent(fileName)
    }
    
    // Save the boards to disk.
    func save(boards: [GameBoard]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(boards)
        guard let url = fileURL else { return }
        try data.write(to: url)
        // Update cache after saving
        cachedBoards = boards
    }
    
    // Load the boards from disk.
    func load() throws -> [GameBoard] {
        // Return cached boards if available
        if let cachedBoards = cachedBoards {
            return cachedBoards
        }
        
        guard let url = fileURL, FileManager.default.fileExists(atPath: url.path) else {
            // Signal that generation is about to start
            generatingSubject.send(true)
            progressSubject.send(0.01)
            
            // If no boards exist, generate a standard set
            let boards = try generateStandardBoards()
            
            // Signal that generation is complete
            generatingSubject.send(false)
            
            return boards
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let boards = try decoder.decode([GameBoard].self, from: data)
        
        // Cache the loaded boards
        cachedBoards = boards
        return boards
    }
    
    // Find a board by its ID
    func findBoard(withID id: String) throws -> GameBoard? {
        let boards = try load()
        return boards.first(where: { $0.id == id })
    }
    
    // Get a random board for a specific difficulty
    func getRandomBoard(for difficulty: DifficultyLevel) throws -> GameBoard? {
        let boards = try load()
        
        // Filter boards by the requested difficulty level
        let filteredBoards = boards.filter { $0.difficulty == difficulty }
        
        // Return a random board from the filtered list
        return filteredBoards.randomElement()
    }
    
    // Generate a standard set of boards (10 per difficulty) with deterministic seeds
    private func generateStandardBoards() throws -> [GameBoard] {
        print("Generating standard board set...")
        var boards: [GameBoard] = []
        
        // Calculate total number of boards to generate
        let totalDifficulties = DifficultyLevel.allCases.count
        let totalBoards = totalDifficulties * boardsPerDifficulty
        var boardsGenerated = 0
        
        // For each difficulty level, generate boards
        for difficulty in DifficultyLevel.allCases {
            for index in 0..<boardsPerDifficulty {
                // Create a deterministic numeric seed for each board
                // Format: <difficulty_index><3-digit_index>
                // This ensures consistent boards across installations
                let difficultyIndex = getDifficultyIndex(difficulty)
                let seedNumber = difficultyIndex * 1000 + index
                let seed = String(format: "%d", seedNumber)
                
                // Generate the board using the numeric seed
                let board = SeededPuzzleGenerator.generatePuzzle(for: difficulty, seed: seed)
                boards.append(board)
                
                // Update progress
                boardsGenerated += 1
                let progress = Double(boardsGenerated) / Double(totalBoards)
                progressSubject.send(progress)
            }
        }
        
        // Ensure 100% is reached at completion
        progressSubject.send(1.0)
        
        // Save the generated boards
        try save(boards: boards)
        
        // Allow a brief delay to show 100% before dismissing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.progressSubject.send(0.0) // Reset progress
        }
        
        return boards
    }
    
    // Helper to get a numeric index for each difficulty level
    private func getDifficultyIndex(_ difficulty: DifficultyLevel) -> Int {
        switch difficulty {
        case .easy:
            return 1
        case .medium:
            return 2
        case .hard:
            return 3
        case .expert:
            return 4
        }
    }
    
    // Clear the cache
    func clearCache() {
        cachedBoards = nil
    }
}
