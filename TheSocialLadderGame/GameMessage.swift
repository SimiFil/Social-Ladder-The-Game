//
//  GameMessage.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 26.01.2025.
//

// MARK: Game Message
enum GameMessage: String, Codable {
    case choosingDeck
    case startGame
    case chosenQuestion
    case chosenPlayerID
    case chosenPlayerName
    case playerOrder
    case roundEnd
    case timerSync
    case playerChoice
    case playerJoined
    case playerLeft
}
