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
                    RoundEndedView(gameManager: gameManager)
                }
            }
            .preferredColorScheme(.dark)
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
                    ToolbarBottomButtons()
                        .padding([.trailing, .bottom], 50)
                        .padding(.bottom)
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
    @State var showLeaveMatchView: Bool = false
    @State var showLeaderboard: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                showLeaderboard.toggle()
            } label: {
                ToolbarButton(iconName: "trophy.fill")
            }
            
            Button {
                showLeaveMatchView.toggle()
            } label: {
                ToolbarButton(iconName: "return", leaving: true)
            }
        }
        .padding(.top, 20)
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(gameManager: gm)
        }
        .sheet(isPresented: $showLeaveMatchView) {
            LeaveMatchView(gm: gm) {
                dismiss()
            }
        }
    }
}

// MARK: Toolbar Bottom Button
struct ToolbarBottomButtons: View {
    @State var isLockedIn: Bool = false
    
    var body: some View {
        // FIXME: fix lockIn button clicking and funcionality
        GeometryReader { geo in
            HStack {
                Spacer()
                
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        isLockedIn.toggle()
                    }
                } label: {
                    VStack(alignment: .center) {
                        Image(systemName: isLockedIn ? "lock.fill" : "lock.open.fill")
                            .imageScale(.large)
                            .opacity(0.8)
                        
                        Text(isLockedIn ? "Locked In" : "Lock In")
                            .minimumScaleFactor(0.5)
                            .font(.title2)
                    }
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.customWhitesmoke)
                    .frame(width: 100, height: 100)
                }
            }
            .padding(.leading, geo.size.width/1.05)
        }
    }
}

// MARK: Toolbar button
struct ToolbarButton: View {
    let iconName: String
    var leaving: Bool = false
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 20))
            .foregroundStyle(leaving ? .black : .textGray)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(leaving ? .red.opacity(0.8) : .black.opacity(0.2))
            )
    }
}

#Preview(traits: .landscapeRight) {
    GamePage(gameManager: GameManager())
}
