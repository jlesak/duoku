//
//  AppCoordinator.swift
//  Duoku
//
//  Created by Jan Lesák on 15.04.2025.
//

import SwiftUI

struct AppCoordinator: View {
    @State private var hasStoredBoards: Bool = false
    @State private var isCheckingStorage: Bool = true
    @StateObject private var generationViewModel = BoardGenerationViewModel(totalBoards: 1000, difficulty: .medium)
    
    var body: some View {
        ZStack {
            if isCheckingStorage {
                ProgressView()
                    .scaleEffect(1.5)
            } else if !hasStoredBoards {
                BoardGenerationView(viewModel: generationViewModel)
            } else {
                HomeView()
            }
        }
        .onAppear {
            checkForStoredBoards()
        }
        .onChange(of: generationViewModel.isGenerationComplete) { isComplete in
            if isComplete {
                hasStoredBoards = true
            }
        }
    }
    
    private func checkForStoredBoards() {
        Task {
            do {
                let boards = try await Task.detached(priority: .userInitiated) { 
                    try GameBoardStore.shared.load()
                }.value
                
                await MainActor.run {
                    hasStoredBoards = !boards.isEmpty
                    isCheckingStorage = false
                }
            } catch {
                print("Error loading game boards: \(error)")
                await MainActor.run {
                    hasStoredBoards = false
                    isCheckingStorage = false
                }
            }
        }
    }
}

struct AppCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        AppCoordinator()
    }
} 