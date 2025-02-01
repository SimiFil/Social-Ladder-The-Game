//
//  GamePage.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI
import GameKit

struct GamePage: View {
    @ObservedObject var gameManager: GameManager
    @State private var hasAppeared = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                switch gameManager.roundState {
                case .roundStart:
                    EmptyView()
                case .playing:
                    RoundPlayingView(gameManager: gameManager)
                case .roundEnd:
                    // this is where i show the user correct answers
                    RoundEndedView(gameManager: gameManager)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    TimeRemainingView(seconds: gameManager.timeRemaining)
                }
                
                ToolbarItem(placement: .principal) {
                    ChosenPlayerView(playerName: gameManager.chosenPlayerName)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarTopButtons(gm: gameManager)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        
                        ToolbarBottomButtons()
                            .ignoresSafeArea()
                            .padding()
                    }
                    .padding(.leading)
                    .padding(.bottom)
                    .padding(.trailing, -50)
                }
            }
            .onAppear {
                if !hasAppeared {
                    gameManager.initializePlayerScoreDict()
                }
            }
        }
    }
}

struct TimeRemainingView: View {
    let seconds: Int
    
    var formattedTime: String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .foregroundStyle(.ultraLightBlue)
            
            Text(formattedTime)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.ultraLightBlue)
                .monospacedDigit()
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

// MARK: Toolbar TOP buttons
struct ToolbarTopButtons: View {
    @ObservedObject var gm: GameManager
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                // Settings action
            } label: {
                ToolbarButton(iconName: "slider.horizontal.3")
            }
            
            Button {
                // Leaderboard action
                LeaderboardView(gameManager: gm) // FIXME: leaderboard view not showing.... use bool and fullDisplayCover
            } label: {
                ToolbarButton(iconName: "trophy.fill")
            }
        }
        .padding(.top, 20)
    }
}

// MARK: Toolbar Bottom Button
struct ToolbarBottomButtons: View {
    var body: some View {
        HStack {
            Button {
                // Leaderboard action
            } label: {
                Text("Lock in")
            }
        }
    }
}

// MARK: Toolbar button
struct ToolbarButton: View {
    let iconName: String
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 20))
            .foregroundStyle(.textGray)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(Color.black.opacity(0.2))
            )
    }
}

#Preview(traits: .landscapeRight) {
    GamePage(gameManager: GameManager())
}
