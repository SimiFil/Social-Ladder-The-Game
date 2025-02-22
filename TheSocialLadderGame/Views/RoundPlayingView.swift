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
    
    @State private var animateViewsIn = false
    
    @State private var dropZoneContents: [Int: String] = [:]
    @State private var dropZoneFrames: [Int: CGRect] = [:]
    
    @State private var draggedItem: String?
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var isTargeted: [Int: Bool] = [:]
    @State private var isFromDropZone: Bool = false
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        self.playerNames = gameManager.players.map { $0.displayName }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppBackground()
                
                if animateViewsIn {
                    // MARK: Round intro animation
                    Text("Round \(gameManager.currentRound + 1)")
                        .font(.largeTitle)
                        .foregroundStyle(.customWhitesmoke)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                        .transition(.move(edge: .top))
                        .zIndex(2)
                        .ignoresSafeArea()
                } else {
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
                                            .background(
                                                GeometryReader { geometry in
                                                    Color.clear.onAppear {
                                                        // Store the frame of each drop zone
                                                        let frame = geometry.frame(in: .global)
                                                        dropZoneFrames[idx] = frame
                                                    }
                                                }
                                            )
                                        
                                        if let playerName = dropZoneContents[idx] {
                                            if !(isDragging && draggedItem == playerName) {
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
                                                                    colors: [Color.cardBlue.opacity(0.6), Color.ultraLightBlue.opacity(0.8)],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                )
                                                            )
                                                    )
                                                    .multilineTextAlignment(.center)
                                                    .minimumScaleFactor(0.5)
                                            }
                                        }
                                    }
                                    .frame(width: min(geo.size.width / 7, geo.size.width / CGFloat(max(7, playerNames.count + 1))), height: geo.size.width / 6)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .allowsHitTesting(!gameManager.isLockedIn)
                                    .gesture(
                                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                            .onChanged { gesture in
                                                if let playerName = dropZoneContents[idx] {
                                                    isFromDropZone = true
                                                    draggedItem = playerName
                                                    isDragging = true
                                                    dragOffset = gesture.translation
                                                    
                                                    for (idx, frame) in dropZoneFrames {
                                                        isTargeted[idx] = frame.contains(gesture.location)
                                                    }
                                                }
                                            }
                                            .onEnded { gesture in
                                                if let playerName = dropZoneContents[idx] {
                                                    handleDrop(at: gesture.location, draggedName: playerName)
                                                }
                                                isFromDropZone = false
                                                draggedItem = nil
                                                isDragging = false
                                                dragOffset = .zero
                                                
                                                for idx in isTargeted.keys {
                                                    isTargeted[idx] = false
                                                }
                                            }
                                    )
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
                                    let _ = draggedItem == name
                                    
                                    PlayerCard(playerName: name)
                                        .offset(x: baseOffset)
                                        .offset(isDragging && draggedItem == name ? dragOffset : .zero)
                                        .rotationEffect(isDragging && draggedItem == name ? .zero : .degrees(Double(index - playerNames.count / 2) * 2.7))
                                        .scaleEffect(isDragging && draggedItem == name ? 1.3 : 1.0)
                                        .opacity(isDragging && draggedItem == name ? 0.8 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                                        .gesture(
                                            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                                .onChanged { gesture in
                                                    draggedItem = name
                                                    isDragging = true
                                                    dragOffset = gesture.translation
                                                    
                                                    for (idx, frame) in dropZoneFrames {
                                                        if frame.contains(gesture.location) {
                                                            isTargeted[idx] = true
                                                        } else {
                                                            isTargeted[idx] = false
                                                        }
                                                    }
                                                }
                                                .onEnded { gesture in
                                                    handleDrop(at: gesture.location, draggedName: name)
                                                    draggedItem = nil
                                                    isDragging = false
                                                    dragOffset = .zero
                                                    
                                                    for idx in isTargeted.keys {
                                                        isTargeted[idx] = false
                                                    }
                                                }
                                        )
                                }
                            }
                        }
                        .frame(height: geo.size.height/4)
                        .offset(y: -geo.size.height/19)
                        .scaleEffect(0.8)
                        .padding(.bottom, 100)
                    }
                    .foregroundStyle(.customWhitesmoke)
                    
                    if isDragging && isFromDropZone, let draggedName = draggedItem {
                        PlayerCard(playerName: draggedName)
                            .opacity(0.8)
                            .offset(dragOffset)
                            .zIndex(100)
                    }
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            if #available(iOS 18.0, *) {
                                LockInButton(gameManager: gameManager)
                                    .symbolEffect(.breathe, options: .repeat(50).speed(0.25), isActive: !gameManager.isLockedIn)
                            } else {
                                LockInButton(gameManager: gameManager)
                            }
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .padding(.bottom, geo.size.height/3)
                }
            }
            .animation(nil, value: dragOffset)
        }
        .toolbar(animateViewsIn ? .hidden : .visible)
        .onAppear {
            withAnimation(.easeIn(duration: 1)) {
                animateViewsIn = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeIn(duration: 1)) {
                    animateViewsIn = false
                }
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
    
    private func handleDrop(at location: CGPoint, draggedName: String) {
        print("Drop location: \(location)")
        print("Current drop zones: \(dropZoneFrames)")
        
        if let (dropZoneIdx, _) = dropZoneFrames.first(where: { $0.value.contains(location) }) {
            print("Dropped in zone: \(dropZoneIdx)")
            
            if let existingPlayer = dropZoneContents[dropZoneIdx] {
                print("Swapping \(draggedName) with \(existingPlayer)")
                if let oldIndex = dropZoneContents.first(where: { $0.value == draggedName })?.key {
                    dropZoneContents[oldIndex] = existingPlayer
                }
                dropZoneContents[dropZoneIdx] = draggedName
            } else {
                print("Placing \(draggedName) in an empty zone")
                if let oldIndex = dropZoneContents.first(where: { $0.value == draggedName })?.key {
                    dropZoneContents.removeValue(forKey: oldIndex)
                }
                dropZoneContents[dropZoneIdx] = draggedName
            }
        } else {
            print("Drop failed: No matching drop zone")
        }
        
        for idx in isTargeted.keys {
            isTargeted[idx] = false
        }
    }
    
    private func codeDict(_ dict: [Int:String]) -> String {
        let keyvals = dict.map { key, value in
            return "\(key):\(value)"
        }.joined(separator: ",")
        
        return keyvals
    }
}

// MARK: Toolbar Bottom Button
struct LockInButton: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                gameManager.isLockedIn.toggle()
                
                if gameManager.isHost {
                    gameManager.playersLockedIn += 1
                    return
                }
                
                let host = gameManager.players.first(where: { $0.gamePlayerID == gameManager.hostID})!
                
                gameManager.sendDataTo(players: [host], data: GameData(messageType: .playerLockedIn, data: [:]))
            }
        } label: {
            VStack(alignment: .center) {
                Image(systemName: gameManager.isLockedIn ? "lock.fill" : "lock.open.fill")
                    .imageScale(.large)
                    .opacity(0.8)
                    .lineLimit(1)
                
                
                Text(gameManager.isLockedIn ? "Locked In" : "Lock In")
                    .font(.title2)
            }
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.customWhitesmoke)
            .frame(width: 100, height: 100)
            .opacity(gameManager.isLockedIn ? 0.5 : 1)
            .minimumScaleFactor(0.5)
        }
        .disabled(gameManager.isLockedIn)
    }
}

#Preview(traits: .landscapeLeft) {
    RoundPlayingView(gameManager: GameManager())
}

//#Preview(traits: .landscapeLeft) {
//    LockInButton(gameManager: GameManager())
//        .preferredColorScheme(.dark)
//}
