//
//  DigitButtonsView.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import SwiftUI

/// A view that displays digit buttons (1–9) for user input.
struct DigitButtonsView: View {
    @ObservedObject var viewModel: SudokuViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(1..<10) { digit in
                Button(action: {
                    viewModel.placeDigit(digit)
                }) {
                    Text("\(digit)")
                        .font(.system(size: 35))
                        .frame(width: 32, height: 50)
                }
            }
        }
    }
}
