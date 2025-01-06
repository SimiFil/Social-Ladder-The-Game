//
//  ContentView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI

struct MainPage: View {
    @StateObject var game: Game = Game()
    
    @State private var animationOffset: CGFloat = -1.0
    @State private var isMusicDisabled: Bool = false
    
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
                        VStack(spacing: 20) {
                            // MARK: PLAY BUTTON
                            Button(action: {
                                // action -> go to connect lobby
                                game.loadQuestions(from: QuestionsType.wildQuestions)
                            }) {
                                HStack {
                                    Image(systemName: "gamecontroller")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .padding(23)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.primaryButtonImageBG, Color.primaryButtonImageBG.opacity(0.8)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 4, y: 4)

                                    Spacer()
                                    
                                    Text("Play")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .padding(.trailing, geo.size.width/19)
                                }
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.activeBlue, Color.activeBlue.opacity(0.8)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 4, y: 4)
                            }
                            
                            // MARK: SETTINGS
                            Button(action: {
                                // action -> go to the about page/sheet
                            }) {
                                Button(action: {
                                    // action -> go to connect lobby
                                }) {
                                    HStack {
                                        Text("Settings")
                                            .font(.title2)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .padding()
                                            .padding(.leading, geo.size.width/19)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "slider.horizontal.3")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .padding(geo.size.height/29)
                                            .frame(minWidth: geo.size.width/9)
                                            .background(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [Color.secondaryButtonImageBg, Color.secondaryButtonImageBg.opacity(0.8)]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            )
                                            .foregroundColor(.white)
                                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 4, y: 4)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.cardBlue, Color.cardBlue.opacity(0.8)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 4, y: 4)
                                }
                            }
                            
                            // MARK: HOW TO PLAY
                            Button(action: {
                                // action -> go to the about page/sheet
                            }) {
                                HStack {
                                    Text("How to play")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding()
                                        .padding(.leading, geo.size.width/19)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "lightbulb.fill")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .padding(geo.size.height/29)
                                        .frame(minWidth: geo.size.width/9)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.secondaryButtonImageBg, Color.secondaryButtonImageBg.opacity(0.8)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .foregroundColor(.white)
                                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 4, y: 4)
                                }
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.cardBlue, Color.cardBlue.opacity(0.8)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 4, y: 4)
                            }
                        }
                        .padding(.horizontal, geo.size.width/13)
                    }
                    .padding(-geo.size.width/20)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("@\(Constants.gameName.removeSpaces())")
                            .font(.headline)
                            .foregroundColor(.textGray)
                            .padding(.top, 25)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isMusicDisabled.toggle()
                        } label: {
                            Image(systemName: isMusicDisabled ? "speaker.slash.fill" : "speaker.wave.3.fill")
                                .foregroundColor(.textGray)
                                .font(.title2)
                                .padding(.top, 25)
                                .animation(.default, value: isMusicDisabled)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isMusicDisabled.toggle()
                        } label: {
                            Image(systemName: "globe")
                                .foregroundColor(.textGray)
                                .font(.title2)
                                .padding(.top, 25)
                                .animation(.default, value: isMusicDisabled)
                        }
                    }
                }
                .preferredColorScheme(.dark)
            }
        }
    }
    
    private func playMusic() -> Bool {
        return true
    }
}

#Preview(traits: .landscapeRight) {
    MainPage()
}

