//
//  ControlButtonsView.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import SwiftUI

/// A view for control buttons: Undo, Erase, and Notes toggle.
struct ControlButtonsView: View {
    @ObservedObject var viewModel: SudokuViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            // Undo button.
            Button(action: {
                viewModel.undo()
            }) {
                Text("Undo")
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Erase button.
            Button(action: {
                viewModel.erase()
            }) {
                Text("Erase")
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Notes mode toggle button.
            Button(action: {
                viewModel.isNotesMode.toggle()
            }) {
                Text(viewModel.isNotesMode ? "Notes (ON)" : "Notes (OFF)")
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }
}
