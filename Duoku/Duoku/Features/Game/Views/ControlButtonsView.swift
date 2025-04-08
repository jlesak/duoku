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
        HStack(spacing: 100) {
            // Erase button with icon and caption.
            Button(action: {
                viewModel.erase()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "eraser")
                        .font(.system(size: 24))
                        .foregroundColor(.primary)
                    Text("Erase")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding()
                .cornerRadius(10)
            }
            
            // Notes toggle switch with caption.
            VStack(spacing: 4) {
                Toggle("", isOn: $viewModel.isNotesMode)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
                Text("Notes")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding()
            .cornerRadius(10)
        }
    }
}
