//
//  DeckCard.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 18.01.2025.
//

import SwiftUI

struct DeckCard: View {
    let type: QuestionsType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Circle()
                    .fill(.ultraThinMaterial.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "book.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
                    }
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    }
                    .padding(.bottom)
                
                Text(type.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 160, height: 200)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.2),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}
