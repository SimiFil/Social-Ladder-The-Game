//
//  LobbyView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 05.01.2025.
//

import SwiftUI

struct LobbyView: View {
    let lobbyMax: Int = 8
    @State private var isSettingsPresented = false
    @State private var canStartGame = false
    
    private let randomColors: [Color] = [.yellow, .orange,  .activeBlue, .customWhitesmoke]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                VStack(alignment: .center, spacing: 20) {
                    // Leader of the lobby
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .imageScale(.medium)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100, alignment: .center)
                        .foregroundStyle(.textGray)
                        .background(.cardBlue)
                        .clipShape(.circle)
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 5, y: 5)
                        .overlay(
                            Circle()
                                .stroke(randomColors.randomElement()!, lineWidth: 5)
                        )
                        .padding(.bottom, 20)
                    
                    // MARK: Rest of the players
                    GeometryReader { geo in
                        HStack(spacing: 38) {
                            ForEach(0..<lobbyMax-1, id: \.self) { index in
                                VStack {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .imageScale(.medium)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 70, height: 70, alignment: .center)
                                        .foregroundStyle(.textGray)
                                        .background(.cardBlue)
                                        .clipShape(.circle)
                                        .shadow(color: .black.opacity(0.15), radius: 5, x: 5, y: 5)
                                        .overlay(
                                            Circle()
                                                .stroke(.white.opacity(0.2), lineWidth: 1.5)
                                        )
                                        .offset(y: index < lobbyMax/2 ?
                                                CGFloat(-(index * 25)) :
                                                    CGFloat((index-lobbyMax/2) * 25 - 40))
                                        .padding(.bottom, 5)
                                    
                                    Text("Nickname")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .offset(y: index < lobbyMax/2 ?
                                                CGFloat(-(index * 25)) :
                                                    CGFloat((index-lobbyMax/2) * 25 - 40))
                                }
                            }
                        }
                        .padding(.top, 200)
                        .padding(.bottom, 100)
                        .padding(.horizontal)
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                    .frame(height: 120)
                    .padding(.bottom)
                    
                    // MARK: Start Button
                    SwipeableStartButton {
                        // Add your game start logic here
                        print("Game Starting...")
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isSettingsPresented.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(.textGray)
                            .font(.largeTitle)
                            .padding(.top, 50)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview(traits: .landscapeLeft) {
    LobbyView()
}
