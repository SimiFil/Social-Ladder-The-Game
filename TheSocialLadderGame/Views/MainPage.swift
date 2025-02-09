//
//  ContentView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI
import AVKit
import GameKit

struct MainPage: View {
    @ObservedObject var gameManager: GameManager
    
    @State private var audioPlayer: AVAudioPlayer!
    @State private var isMusicDisabled: Bool = false
    @State private var volume: Float = 1.0
    
    @State private var showGameModeView: Bool = false
    @State private var showSettings: Bool = false
    @State private var showHowToPlayView: Bool = false
    
    @State private var animated = false
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    AppBackground()
                    
                    HStack {
                        // MARK: BUTTONS
                        VStack(spacing: geo.size.height * 0.05) {
                            // MARK: PLAY BUTTON
                            MainButton(action: {
                                showGameModeView = true
                                GKAccessPoint.shared.isActive = false
                            }, title: "Play", icon: "gamecontroller", isLeadingIcon: true, isEnabled: gameManager.playerAuthState == .authenticated, geo: geo)
                            .disabled(gameManager.playerAuthState != .authenticated)
                            
                            // MARK: HOW TO PLAY
                            MainButton(action: {
                                showHowToPlayView = true
                            }, title: "How To Play", icon: "lightbulb.max.fill", isLeadingIcon: false, isEnabled: true, geo: geo, isHowToPlayButton: true)
                            
                            // MARK: SETTINGS
                            MainButton(action: {
                                showSettings = true
                            }, title: "Settings", icon: "slider.horizontal.3", isLeadingIcon: false, isEnabled: true, geo: geo)
                        }
                        .padding(.horizontal, geo.size.width/4)
                    }
                    .lineLimit(1)
                    .padding(-geo.size.width/20)
                    .padding(.top, gameManager.playerAuthState == .unauthenticated ? geo.size.height/8 : geo.size.height/5)
                }
                .navigationDestination(isPresented: $showGameModeView, destination: {
                    SelectGameModeView(gameManager: gameManager)
                })
                .fullScreenCover(isPresented: $gameManager.showMatchView) {
                    MatchView(gameManager: gameManager)
                        .onAppear { GKAccessPoint.shared.isActive = false }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(alignment: .leading) {
                           Text(Constants.gameName.uppercased())
                        }
                        .font(.largeTitle)
                        .foregroundStyle(
                            LinearGradient(colors: [.white, .customWhitesmoke, .ultraLightBlue],
                                          startPoint: .top,
                                          endPoint: .bottom)
                        )
                        .shadow(color: .white.opacity(0.3), radius: 10, y: -5)
                        .fontWeight(.bold)
                        .padding(.top, geo.size.height/6)
                        .offset(y: animated ? 0 : -100 )
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2)) {
                                animated = true
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        Text(gameManager.playerAuthState.rawValue)
                            .font(.headline)
                            .foregroundColor(.yellow.opacity(0.7))
                            .padding(.top, 20)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                isMusicDisabled.toggle()
                            }
                            
                            if isMusicDisabled {
                                audioPlayer.pause()
                            } else {
                                audioPlayer.play()
                            }
                        } label: {
                            HStack {
                                Image(systemName: isMusicDisabled ? "speaker.slash.fill" : "speaker.wave.3.fill")
                                    .foregroundColor(.textGray)
                                    .font(.title2)
                                    .padding()
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                            }
                            .padding()
                            .padding(.top, geo.size.height/7)
                        }
                    }
                }
                .preferredColorScheme(.dark)
                .onAppear {
                    playAudio()
                    gameManager.authenticatePlayer()
                    
                    // Show Game Center access point
                    GKAccessPoint.shared.showHighlights = false
                    GKAccessPoint.shared.location = .topLeading
                    GKAccessPoint.shared.isActive = true
                }
                .onDisappear(perform: {
                    animated = false
                })
                .fullScreenCover(isPresented: $showSettings) {
                    SettingsView(audioPlayer: audioPlayer, volume: $volume)
                        .onAppear { GKAccessPoint.shared.isActive = false }
                        .onDisappear { GKAccessPoint.shared.isActive = true }
                }
                .fullScreenCover(isPresented: $showHowToPlayView) {
                    HowToPlayView()
                        .onAppear { GKAccessPoint.shared.isActive = false }
                        .onDisappear { GKAccessPoint.shared.isActive = true }
                }
                //                .alert("Game Center Required",
                //                       isPresented: $gameManager.showGameCenterSettings) {
                //                    Button("Open Settings") {
                //                        if let url = URL(string: UIApplication.openSettingsURLString) {
                //                            UIApplication.shared.open(url)
                //                        }
                //                    }
                //
                //                    Button("Cancel", role: .cancel) {
                //                        gameManager.showGameCenterSettings = false
                //                    }
                //                } message: {
                //                    Text("Please sign in to Game Center to play multiplayer games.")
                //                }
            }
        }
    }
    
    private func playAudio() {
        if audioPlayer != nil {
            return
        }
        
        guard let sound = Bundle.main.path(forResource: "lobbyMusic", ofType: "mp3") else {
            print("Could not find audio file")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(filePath: sound))
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = volume
            if !isMusicDisabled {
                audioPlayer?.play()
            }
        } catch {
            print("Could not create audio player: \(error)")
        }
    }
}

#Preview(traits: .landscapeRight) {
    MainPage(gameManager:  GameManager())
}

