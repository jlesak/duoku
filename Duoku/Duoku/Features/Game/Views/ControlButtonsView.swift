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
    @State private var showingShareSheet = false
    @State private var boardIDCopied = false
    
    var body: some View {
        HStack(spacing: 70) {
            // Share button with icon and caption
            Button(action: {
                showingShareSheet = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 24))
                        .foregroundColor(.primary)
                    Text("Share")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding()
                .cornerRadius(10)
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareBoardView(boardID: viewModel.gameManager.gameBoard.id, isPresented: $showingShareSheet)
            }
            
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

struct ShareBoardView: View {
    let boardID: String
    @Binding var isPresented: Bool
    @State private var isCopied = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Share Board ID")
                    .font(.headline)
                    .padding(.top)
                
                Text("Other players can use this code to play the same board:")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(boardID)
                    .font(.title3)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                Button(action: {
                    UIPasteboard.general.string = boardID
                    isCopied = true
                    
                    // Reset the copied state after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isCopied = false
                    }
                }) {
                    HStack {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        Text(isCopied ? "Copied!" : "Copy Board ID")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isCopied ? Color.green : Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}
