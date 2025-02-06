//
//  RoundPlayingView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 27.01.2025.
//

import SwiftUI
import GameKit

struct RoundPlayingView: View {
    @ObservedObject var gameManager: GameManager
    private var playerNames: [String]
    
    @State private var dropZoneContents: [Int: String] = [:]
    @State private var draggedItem: String?
    @State private var isTargeted: [Int: Bool] = [:]
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        self.playerNames = gameManager.players.map { $0.displayName }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppBackground()
                
                VStack(alignment: .center) {
                    // MARK: Question
                    Text(LocalizedStringKey(gameManager.currentQuestion ?? "Question was NOT found"))
                        .font(.title)
                        .frame(width: geo.size.width/2, height: geo.size.height/6)
                        .padding(.top, geo.size.width/30)
                        .padding(.bottom, geo.size.height/20)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
                    // MARK: Player boxes
                    HStack(spacing: 10) {
                        ForEach(Array(playerNames.enumerated()), id: \.0) { idx, name in
                            VStack(alignment: .leading) {
                                // Label
                                if idx == 0 {
                                    Text("Most")
                                        .foregroundStyle(.green)
                                        .padding(.leading, 5)
                                } else if idx == (playerNames.count - 1) {
                                    HStack {
                                        Spacer()
                                        Text("Least")
                                            .foregroundStyle(.red)
                                            .padding(.trailing, 5)
                                    }
                                } else {
                                    Text("")
                                        .font(.caption)
                                        .frame(height: geo.size.height/17)
                                }
                                
                                // MARK: Drop zones
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isTargeted[idx] == true ? Color.blue.opacity(0.3) : Color.textGray)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(isTargeted[idx] == true ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                        .multilineTextAlignment(.center)
                                    
                                    if let playerName = dropZoneContents[idx] {
                                        Text(playerName)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(maxHeight: .infinity)
                                            .padding(.horizontal)
                                            .padding(.vertical, 5)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.8)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            )
                                            .multilineTextAlignment(.center)
                                            .minimumScaleFactor(0.5)
                                    }
                                }
                                .frame(width: min(geo.size.width / 7, geo.size.width / CGFloat(max(7, playerNames.count + 1))), height: geo.size.width / 6)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .draggable(dropZoneContents[idx] ?? "") {
                                    if let playerName = dropZoneContents[idx] {
                                        PlayerCard(playerName: playerName)
                                    }
                                }
                                .dropDestination(for: String.self) { playerCards, _ in
                                    if let droppedPlayer = playerCards.first {
                                        if let existingPlayer = dropZoneContents[idx] {
                                            if let oldIndex = dropZoneContents.first(where: { $0.value == droppedPlayer })?.key {
                                                dropZoneContents[oldIndex] = existingPlayer
                                                dropZoneContents[idx] = droppedPlayer
                                            } else {
                                                dropZoneContents[idx] = droppedPlayer
                                            }
                                        } else {
                                            if let oldIndex = dropZoneContents.first(where: { $0.value == droppedPlayer })?.key {
                                                dropZoneContents.removeValue(forKey: oldIndex)
                                            }
                                            dropZoneContents[idx] = droppedPlayer
                                        }
                                    }
                                    isTargeted[idx] = false
                                    return true
                                } isTargeted: { targeted in
                                    isTargeted[idx] = targeted
                                }
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                        }
                    }
                    .padding(.horizontal, playerNames.count <= 6
                             ? (geo.size.width - (geo.size.width / 7 * CGFloat(playerNames.count) + 10 * CGFloat(playerNames.count - 1))) / 2
                             : 20)
                    .padding(.bottom, 20)
                    .minimumScaleFactor(0.6)
                    
                    // MARK: Player cards
                    ZStack {
                        ForEach(Array(playerNames.enumerated()), id: \.0) { index, name in
                            if !dropZoneContents.values.contains(name) {
                                let baseOffset = CGFloat(index - playerNames.count / 2) * 60
                                let isBeingDragged = draggedItem == name
                                
                                PlayerCard(playerName: name)
                                    .offset(x: baseOffset)
                                    .rotationEffect(.degrees(Double(index - playerNames.count / 2) * 2.7))
                                    .scaleEffect(isBeingDragged ? 1.5 : 1.0)
                                    .opacity(isBeingDragged ? 0 : 1)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isBeingDragged)
                                    .draggable(name) {
                                        PlayerCard(playerName: name)
                                    }
                            }
                        }
                    }
                    .frame(height: geo.size.height/4)
                    .offset(y: -geo.size.height/19)
                    .scaleEffect(0.8)
                    .padding(.bottom, 100)
                }
                .foregroundStyle(.customWhitesmoke)
            }
        }
        .onReceive(gameManager.$roundState) { newState in
            if newState == .roundEnd {
                let codedMSG: String = codeDict(dropZoneContents)
                
                // set player's order
                gameManager.playerCardsOrder = codedMSG.decodePlayersDictString(players: gameManager.players)
                
                if gameManager.isHost {
                    gameManager.playerOrderDict[gameManager.localPlayer.displayName] = codedMSG.decodePlayersDictString(players: gameManager.players)
                } else {
                    guard let host = gameManager.players.first(where: { $0.gamePlayerID == gameManager.hostID }) else {
                        print("Error: Could not find host player")
                        return
                    }
                    
                    gameManager.sendDataTo(players: [host], data: GameData(messageType: .playerChoice, data: ["playerGameOrder":codedMSG]))
                }
            }
        }
    }
    
    private func codeDict(_ dict: [Int:String]) -> String {
        let keyvals = dict.map { key, value in
            return "\(key):\(value)"
        }.joined(separator: ",")
        
        return keyvals
    }
}

// MARK: Player Card
struct PlayerCard: View {
    let playerName: String
    
    var body: some View {
        Text(playerName)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .frame(width: 100, height: 160)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: Chosen Player
struct ChosenPlayerView: View {
    let playerName: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text("👑")
                .font(.title2)
            
            Text(playerName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.2))
        )
        .padding(.top, 20)
    }
}

#Preview(traits: .landscapeLeft) {
    RoundPlayingView(gameManager: GameManager())
}
