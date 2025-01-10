////
////  GameManager+GKMatchDelegate.swift
////  TheSocialLadderGame
////
////  Created by Filip Simandl on 10.01.2025.
////
//
//import Foundation
//import GameKit
//
//extension GameManager: GKMatchDelegate {
//    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
//        do {
//            let gameData = try JSONDecoder().decode(GameData.self, from: data)
//            
//            DispatchQueue.main.async { [weak self] in
//                switch gameData.messageType {
//                case .startGame:
//                    self?.gameState = .choosingQuestions
//                case .playerChoice:
//                    if let playerId = gameData.data["playerId"] {
//                        self?.isTheChosenOne = playerId == self?.localPlayer.gamePlayerID
//                    }
//                case .playerOrder:
//                    if let orderString = gameData.data["order"] {
//                        self?.playerOrder = orderString.split(separator: ",").map(String.init)
//                    }
//                case .roundEnd:
//                    self?.currentRound += 1
//                case .notEnoughPlayers:
//                    if let required = gameData.data["required"] {
//                        self?.errorMessage = "Need at least \(required) players to start the game"
//                    }
//                }
//            }
//        } catch {
//            errorMessage = "Failed to process game data: \(error.localizedDescription)"
//        }
//    }
//    
//    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
//        DispatchQueue.main.async { [weak self] in
//            switch state {
//            case .connected:
//                self?.players = match.players
//            case .disconnected:
//                self?.players = match.players
//                if let self = self, self.players.count < self.minPlayers {
//                    self.errorMessage = "Not enough players to continue. Need at least \(self.minPlayers) players."
//                    self.gameState = .finished
//                }
//            default:
//                break
//            }
//        }
//    }
//}
