//
//  ContentView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI
import AVKit

struct MainPage: View {
    @ObservedObject var gameManager: GameManager
    
    @State private var audioPlayer: AVAudioPlayer!
    @State private var isMusicDisabled: Bool = false
    @State private var volume: Float = 1.0
    
    @State private var showGameModeView: Bool = false
    @State private var showSettings: Bool = false
    @State private var showHowToPlayView: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    AppBackground()
                    
                    HStack {
                        // MARK: LOGO & TITLE
                        VStack {
                            Text(Constants.gameName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                                .minimumScaleFactor(0.5)
                            
                            Image(systemName: "person.3.fill")
                                .imageScale(.large)
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, geo.size.width/13)
                        
                        // MARK: BUTTONS
                        VStack(spacing: geo.size.height * 0.05) {
                            // MARK: PLAY BUTTON
                            MainButton(action: {
                                showGameModeView = true
                            }, title: "Play", icon: "gamecontroller", isLeadingIcon: true, isEnabled: gameManager.playerAuthState == .authenticated, geo: geo)
                            .disabled(gameManager.playerAuthState != .authenticated)
                            
                            // MARK: SETTINGS
                            MainButton(action: {
                                showSettings = true
                            }, title: "Settings", icon: "slider.horizontal.3", isLeadingIcon: false, isEnabled: true, geo: geo)
                            
                            // MARK: HOW TO PLAY
                            MainButton(action: {
                                showHowToPlayView = true
                            }, title: "How To Play", icon: "lightbulb.max.fill", isLeadingIcon: false, isEnabled: true, geo: geo, isHowToPlayButton: true)
                        }
                        .padding(.horizontal, geo.size.width/13)
                    }
                    .lineLimit(1)
                    .padding(-geo.size.width/20)
                }
                .navigationDestination(isPresented: $showGameModeView, destination: {
                    SelectGameModeView(gameManager: gameManager);
                })
                .fullScreenCover(isPresented: $gameManager.showMatchView) {
                    MatchView(gameManager: gameManager)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("@\(Constants.gameName.removeSpaces())")
                            .font(.headline)
                            .foregroundColor(.textGray)
                            .padding(.top, 20)
                    }
                    
                    ToolbarItem(placement: .principal) {
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
                            Image(systemName: isMusicDisabled ? "speaker.slash.fill" : "speaker.wave.3.fill")
                                .foregroundColor(.textGray)
                                .font(.title2)
                                .padding(.top, 20)
                                .animation(.default, value: isMusicDisabled)
                        }
                    }
                }
                .preferredColorScheme(.dark)
                .onAppear {
                    playAudio()
                    gameManager.authenticatePlayer()
                }
                .alert("Game Center Required",
                       isPresented: $gameManager.showGameCenterSettings) {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    Button("Cancel", role: .cancel) {
                        gameManager.showGameCenterSettings = false
                    }
                } message: {
                    Text("Please sign in to Game Center to play multiplayer games.")
                }
                .fullScreenCover(isPresented: $showSettings) {
                    SettingsView(audioPlayer: audioPlayer, volume: $volume)
                }
                .fullScreenCover(isPresented: $showHowToPlayView) {
                    HowToPlayView()
                }
            }
        }
    }
    
    private func playAudio() {
        guard let sound = Bundle.main.path(forResource: "lobbyMusic", ofType: "mp3") else {
                    print("Could not find audio file")
                    return
                }
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(filePath: sound))
                    audioPlayer?.numberOfLoops = -1 // infinity
                    audioPlayer?.volume = volume
                    if !isMusicDisabled {
                        audioPlayer?.play()
                    }
                } catch {
                    print("Could not create audio player: \(error.localizedDescription)")
                }
    }
}

#Preview(traits: .landscapeRight) {
    MainPage(gameManager:  GameManager())
}

