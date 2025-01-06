//
//  Player.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 05.01.2025.
//

import Foundation

struct Player: Codable, Identifiable {
    let id: UUID
    let username: String
    var avatar: String? // image
    var score: Int = 0
    var isLobbyLeader: Bool = false
    var isTheChosenOne: Bool = false
    var playerGuessOrder: [Int:String] = [:]
}
