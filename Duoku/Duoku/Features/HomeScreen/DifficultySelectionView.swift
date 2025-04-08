//
//  DifficultySelectionView.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import SwiftUI




struct DifficultySelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    // Closure to pass back the selected difficulty level.
    var onDifficultySelected: (DifficultyLevel) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20.0,) {
                Spacer()
                Text("Select Difficulty")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                    Button(action: {
                        onDifficultySelected(level)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(level.rawValue)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
            .scaledToFit()
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            })
        }
    }
}

struct DifficultySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DifficultySelectionView {
            _ in
        }
    }
}

