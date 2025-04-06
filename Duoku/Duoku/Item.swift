//
//  Item.swift
//  Duoku
//
//  Created by Jan Lesák on 06.04.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
