//
//  GameState.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 26.01.2025.
//

import Foundation

// MARK: Game State
enum GameState: String, Codable {
    case waitingForPlayers
    case choosingQuestions
    case playing
    case talking
    case finished
}
