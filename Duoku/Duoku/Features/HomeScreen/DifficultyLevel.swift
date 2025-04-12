//
//  DifficultyLevel.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//


import SwiftUI
import Foundation

enum DifficultyLevel: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
//    case evil = "Evil"
}
