import Foundation

/// The PuzzleGenerator class is responsible for generating a new Sudoku puzzle and its solution based on a selected difficulty level.
/// The generation process follows these steps:
/// 1. Generate a complete and valid Sudoku board using a backtracking algorithm.
/// 2. Remove numbers from the solved board based on the difficulty level while ensuring the resulting puzzle has a unique solution.

class SeededPuzzleGenerator {
    /// The size of the Sudoku board (9x9).
    private static let boardSize: Int = 9
    /// The size of a subgrid (3x3).
    private static let subgridSize: Int = 3
    
    /// Generates a new Sudoku puzzle along with its complete solution using the system random generator.
    ///
    /// - Parameter difficulty: The difficulty level that affects how many cells will be emptied.
    /// - Returns: A GameBoard object containing the puzzle and solution.
    static func generatePuzzle(for difficulty: DifficultyLevel) -> GameBoard {
        // Generate a unique seed for this board
        let seed = UUID().uuidString
        return generatePuzzle(for: difficulty, seed: seed)
    }
    
    /// Generates a new Sudoku puzzle based on a seed. The same seed and difficulty will always generate the same board.
    ///
    /// - Parameters:
    ///   - difficulty: The difficulty level for puzzle generation.
    ///   - seed: A string that is used to seed the random number generator.
    /// - Returns: A GameBoard object containing the puzzle and solution.
    static func generatePuzzle(for difficulty: DifficultyLevel, seed: String) -> GameBoard {
        // Convert the seed string into a numeric value.
        let seedValue = UInt64(abs(seed.hashValue))
        var seededRNG = SeedGenerator(state: seedValue)
        
        // Generate the board using the seeded random number generator
        var solvedBoard = Array(repeating: Array(repeating: 0, count: boardSize), count: boardSize)
        guard fillBoard(&solvedBoard, using: &seededRNG) else {
            fatalError("Failed to generate a complete Sudoku solution board.")
        }
        
        var puzzleBoard = solvedBoard
        let cellsToRemove = numberOfCellsToRemove(for: difficulty)
        removeCells(&puzzleBoard, cellsToRemove: cellsToRemove, using: &seededRNG)
        
        // Create a short numeric ID using the seed's hash value
        // Using a consistent algorithm ensures the same board ID across installations
        let hashValue = abs(seed.hashValue)
        let boardId = String(format: "%08d", hashValue % 100000000) // 8-digit ID
        
        // Return a GameBoard object with the seed and difficulty
        return GameBoard(id: boardId, 
                         puzzle: puzzleBoard, 
                         solution: solvedBoard, 
                         difficulty: difficulty, 
                         seed: seed)
    }
    
    /// Fills the board completely using a backtracking algorithm while using the provided generator for deterministic shuffling.
    private static func fillBoard<T: RandomNumberGenerator>(_ board: inout [[Int]], using rng: inout T) -> Bool {
        guard let (row, col) = findEmptyCell(in: board) else {
            return true // The board is completely filled.
        }
        
        var numbers = Array(1...boardSize)
        numbers.shuffle(using: &rng) // Use the seeded generator for deterministic ordering.
        
        for number in numbers {
            if isValid(board, number: number, row: row, col: col) {
                board[row][col] = number
                if fillBoard(&board, using: &rng) {
                    return true
                }
                board[row][col] = 0
            }
        }
        
        return false
    }
    
    /// Finds the first empty cell (i.e. a cell with value 0) in the board.
    private static func findEmptyCell(in board: [[Int]]) -> (Int, Int)? {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                if board[row][col] == 0 {
                    return (row, col)
                }
            }
        }
        return nil
    }
    
    /// Checks if placing a number in the specified cell is valid according to Sudoku rules.
    private static func isValid(_ board: [[Int]], number: Int, row: Int, col: Int) -> Bool {
        // Check the row.
        if board[row].contains(number) {
            return false
        }
        // Check the column.
        for i in 0..<boardSize {
            if board[i][col] == number {
                return false
            }
        }
        // Check the 3x3 subgrid.
        let startRow = (row / subgridSize) * subgridSize
        let startCol = (col / subgridSize) * subgridSize
        for i in 0..<subgridSize {
            for j in 0..<subgridSize {
                if board[startRow + i][startCol + j] == number {
                    return false
                }
            }
        }
        return true
    }
    
    /// Determines the number of cells to remove from a full board based on the selected difficulty.
    private static func numberOfCellsToRemove(for difficulty: DifficultyLevel) -> Int {
        switch difficulty {
        case .easy:
            return 30  // About 51 prefilled cells.
        case .medium:
            return 40  // About 41 prefilled cells.
        case .hard:
            return 50  // About 31 prefilled cells.
        case .expert:
            return 55  // About 26 prefilled cells.
//        case .evil:
//            return 60  // About 21 prefilled cells.
        }
    }
    
    /// Removes cells from the board deterministically while ensuring the resulting puzzle remains uniquely solvable.
    /// Uses the seeded RNG to ensure the same cells are removed for the same seed.
    private static func removeCells<T: RandomNumberGenerator>(_ board: inout [[Int]], cellsToRemove: Int, using rng: inout T) {
        var removedCells = 0
        var cellPositions = [(row: Int, col: Int)]()
        
        // Create an ordered list of all cell positions
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                cellPositions.append((row, col))
            }
        }
        
        // Shuffle using the seeded RNG to ensure deterministic ordering
        cellPositions.shuffle(using: &rng)
        
        // Remove cells in the deterministic order
        for position in cellPositions {
            if removedCells >= cellsToRemove {
                break
            }
            let backupValue = board[position.row][position.col]
            board[position.row][position.col] = 0
            
            // Check if the board still has a unique solution.
            if !isUniquePuzzle(board) {
                board[position.row][position.col] = backupValue
            } else {
                removedCells += 1
            }
        }
    }
    
    /// Validates if the puzzle has a unique solution using a backtracking solution counter.
    private static func isUniquePuzzle(_ board: [[Int]]) -> Bool {
        var solutionCounter = 0
        var boardCopy = board
        
        func countSolutions(_ board: inout [[Int]]) {
            guard let (row, col) = findEmptyCell(in: board) else {
                solutionCounter += 1
                return
            }
            
            for number in 1...boardSize {
                if isValid(board, number: number, row: row, col: col) {
                    board[row][col] = number
                    countSolutions(&board)
                    if solutionCounter > 1 { return }
                    board[row][col] = 0
                }
            }
        }
        
        countSolutions(&boardCopy)
        return solutionCounter == 1
    }
}
