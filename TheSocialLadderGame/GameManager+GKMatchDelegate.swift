//
//  GameManager+GKMatchDelegate.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 10.01.2025.
//

import Foundation
import GameKit

extension GameManager: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        do {
            let gameData = try JSONDecoder().decode(GameData.self, from: data)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                print("Received game message: \(gameData.messageType) from \(player.displayName)")
                
                switch gameData.messageType {
                case .hostID:
                    if let hostID = gameData.data["hostID"] {
                        self.hostID = hostID
                    }
                case .choosingDeck:
                    self.gameState = .choosingQuestions
                    self.showMatchView = true
                case .playerOrder:
                    if let playerOrderStr = gameData.data["playerOder"] {
                        self.playerOrder = playerOrderStr.split(separator: ",").map{ String($0) }
                    }
                case .startGame:
                    self.gameState = .playing
                    self.showMatchView = true
                    
                    self.currentRound = 0
                    self.playerOrder.removeAll()
                    self.playerOrderDict.removeAll()
                    self.playerScoreDict.removeAll()
                case .playerCount:
                    if let playerCount = gameData.data["playerCount"] {
                        self.playersCount = Int(playerCount)!
                    }
                case .playerChoice:
                    if let playerGameOrder = gameData.data["playerGameOrder"] {
                        self.playerOrderDict[player.displayName] = playerGameOrder.decodePlayersDictString(players: self.players)
                        
                        if self.isHost {
                            self.receivedResponsesCount += 1
                            
                            // only resolve when all responses are received
                            if self.receivedResponsesCount == self.players.count - 1 {
                                self.resolveScore()
                            }
                        }
                    }
                case .playerLockedIn:
                    print("\(player.displayName) is locked IN")
                    self.playersLockedIn += 1
                case .playerScore:
                    if let playersScore = gameData.data["playerScore"] {
                        let decodedMSG = playersScore.split(separator: ",").map(String.init)
                        print("\(decodedMSG)") // example: ["HranýŠmoula68:3", "SimiFil:0"]
                        
                        for item in decodedMSG {
                            let parts = item.split(separator: ":").map(String.init)
                            if parts.count == 2 {
                                let playerName = parts[0]
                                self.playerScoreDict[playerName]?.append(Int(parts[1])!)
                            }
                        }
                        
                        print(self.playerScoreDict)
                    }
                case .chosenQuestion:
                    if let chosenQuestion = gameData.data["currentQuestion"] {
                        self.currentQuestion = chosenQuestion
                    }
                case .chosenPlayerID:
                    if let chosenPlayerID = gameData.data["chosenPlayerID"] {
                        self.chosenPlayerID = chosenPlayerID
                    }
                case .chosenPlayerName:
                    if let chosenPlayerName = gameData.data["chosenPlayerName"] {
                        self.chosenPlayerName = chosenPlayerName
                    }
                case .chosenPlayerOrder:
                    if let chosenPlayerOrder = gameData.data["chosenPlayerOrder"] {
                        self.chosenPlayerOrder = chosenPlayerOrder.split(separator: ",").map(String.init)
                    }
                case .roundState:
                    self.roundState = gameData.data["roundPlaying"] != nil ? .playing : .roundEnd
                    if roundState == .roundEnd {
                        self.currentRound += 1
                        self.isLockedIn = true
                    } else if roundState == .playing {
                        self.isLockedIn = false
                    }
                case .timerSync:
                    if !self.isHost, let timeStr = gameData.data["timeRemaining"], let time = Int(timeStr) {
                        self.timeRemaining = time
                    }
                case .gameEnded:
                    self.gameState = .finished
                case .disconnected:
                    if let match = self.match {
                        match.delegate = nil
                        match.disconnect()
                    }
                    self.players.removeAll(where: { $0.gamePlayerID == player.gamePlayerID })
                    self.match = nil
                    self.gameState = .finished
                }
            }
        } catch {
            print("Failed to process game data: \(error)")
            errorMessage = "Failed to process game data: \(error.localizedDescription)"
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("\n--- Connection State Change ---")
            print("Player \(player.displayName) state: \(state)")
            print("Local player: \(self.localPlayer.displayName)")
            print("Is host: \(self.isHost)")
            
            switch state {
            case .connected:
                if !self.players.contains(player) {
                    self.players.append(player)
                    print("Player added to list")
                }
                
                if self.isHost {
                    print("Host sending current game state")
                    let gameData = GameData(
                        messageType: .choosingDeck,
                        data: [:]
                    )
                    self.sendDataTo(data: gameData)
                }
                
            case .disconnected:
                self.players.removeAll { $0 == player }
                print("Player removed, remaining: \(self.players.map { $0.displayName })")
                
                if player.gamePlayerID == self.hostID || self.players.count < self.minPlayers {
                    self.errorMessage = "Not enough players to continue. Need at least \(self.minPlayers) players."
                    self.gameState = .waitingForPlayers
                }
                
            default:
                break
            }
            
            print("Final players count: \(self.players.count)")
        }
    }
}
