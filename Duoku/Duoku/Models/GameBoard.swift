import Foundation

// Represents a single game board with puzzle and solution.
// Conforms to Codable (if needed for serialization) and Identifiable.
struct GameBoard: Codable, Identifiable {
    let id: String
    let puzzle: [[Int]]
    let solution: [[Int]]
    let difficulty: DifficultyLevel
    let seed: String // Store the original seed used to generate the board
    
    init(id: String, puzzle: [[Int]], solution: [[Int]], difficulty: DifficultyLevel, seed: String) {
        self.id = id
        self.puzzle = puzzle
        self.solution = solution
        self.difficulty = difficulty
        self.seed = seed
    }
}
