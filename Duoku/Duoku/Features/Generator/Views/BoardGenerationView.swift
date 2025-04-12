//
//  BoardGenerationView.swift
//  Duoku
//
//  Created by Jan Lesák on 15.04.2025.
//

import SwiftUI

struct BoardGenerationView: View {
    @ObservedObject var viewModel: BoardGenerationViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("Duoku")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            VStack(spacing: 20) {
                Text("Generating Game Boards")
                    .font(.title2)
                    .fontWeight(.medium)
                
                ProgressView(value: viewModel.generationProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 8)
                    .padding(.horizontal, 40)
                
                Text("\(Int(viewModel.generationProgress * 100))%")
                    .font(.headline)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
        .task {
            await viewModel.generateBoards()
        }
    }
}

struct BoardGenerationView_Previews: PreviewProvider {
    static var previews: some View {
        BoardGenerationView(viewModel: BoardGenerationViewModel())
    }
}
