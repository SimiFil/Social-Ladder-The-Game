//
//  GameData.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 26.01.2025.
//

struct GameData: Codable {
    let messageType: GameMessage
    let data: [String: String]
}
