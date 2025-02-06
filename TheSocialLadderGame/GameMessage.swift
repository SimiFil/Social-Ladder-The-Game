//
//  GameMessage.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 26.01.2025.
//

import Foundation

// MARK: Game Message
enum GameMessage: String, Codable {
    case hostID
    case choosingDeck
    case startGame
    case chosenQuestion
    case chosenPlayerID
    case chosenPlayerName
    case chosenPlayerOrder
    case roundState
    case playerOrder
    case playerLockedIn
    case timerSync
    case playerChoice
    case playerScore
    case gameEnded
    case disconnected
}
