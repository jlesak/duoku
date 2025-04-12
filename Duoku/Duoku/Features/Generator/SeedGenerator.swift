//
//  SeededGenerator.swift
//  Duoku
//
//  Created by Jan Lesák on 11.04.2025.
//


import Foundation

/// A simple deterministic random number generator based on a linear congruential generator (LCG). 
struct SeedGenerator: RandomNumberGenerator { var state: UInt64
    
    mutating func next() -> UInt64 {
        // Constants from Numerical Recipes; using multiplication and addition mod 2^64.
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}
