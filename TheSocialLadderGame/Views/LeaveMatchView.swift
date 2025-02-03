//
//  LeaveMatchView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 02.02.2025.
//

import SwiftUI

struct LeaveMatchView: View {
    @ObservedObject var gm: GameManager
    @Environment(\.dismiss) var dismiss
    var onLeave: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppBackground()
                
                VStack {
                    Text("Are you sure you want to leave the match?")
                        .font(.title)
                        .padding(.bottom, geo.size.width/15)
                    
                    HStack(alignment: .center, spacing: 20) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Return to Game")
                                .font(.title2)
                                .font(.headline)
                                .frame(width: geo.size.width * 0.3)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            gm.sendDataTo(data: GameData(messageType: .disconnected, data: [:]))
                            onLeave()
                            gm.match?.disconnect()
                            dismiss()
                            gm.match = nil
                        } label: {
                            Text("Leave Match")
                                .font(.title2)
                                .font(.headline)
                                .frame(width: geo.size.width * 0.3)
                                .padding()
                                .background(.red)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                .foregroundStyle(.white)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    LeaveMatchView(gm: GameManager()) {
        
    }
}
