//
//  GameMessage.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 26.01.2025.
//

import Foundation

// MARK: Game Message
enum GameMessage: String, Codable {
    case choosingDeck
    case startGame
    case chosenQuestion
    case chosenPlayerID
    case chosenPlayerName
    case roundState
    case playerOrder
    case timerSync
    case playerChoice
    case playerJoined
    case playerLeft
}
