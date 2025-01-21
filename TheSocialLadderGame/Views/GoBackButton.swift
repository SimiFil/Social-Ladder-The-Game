//
//  GoBackButton.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 21.01.2025.
//

import SwiftUI

struct GoBackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.left")
                    .foregroundStyle(Color.textGray)
                Text("Go Back")
                    .foregroundStyle(Color.white.opacity(0.9))
            }
            .padding(13)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.cardBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    GoBackButton()
        .preferredColorScheme(.dark)
}
