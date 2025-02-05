//
//  MainPageButton.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 20.01.2025.
//

import SwiftUI

struct MainButton: View {
    let action: () -> Void
    let title: LocalizedStringKey
    let icon: String
    let isLeadingIcon: Bool
    let isEnabled: Bool
    let geo: GeometryProxy
    var isHowToPlayButton: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLeadingIcon {
                    iconView
                    Spacer()
                    titleView
                } else {
                    titleView
                    Spacer()
                    iconView
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: backgroundColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 4, y: 4)
        }
        .disabled(!isEnabled)
    }
    
    private var titleView: some View {
        Text(title)
            .font(isLeadingIcon ? .title : .title2)
            .fontWeight(isLeadingIcon ? .bold : .medium)
            .foregroundColor(.white)
            .padding()
            .padding(isLeadingIcon ? .trailing : .leading, geo.size.width * 0.05)
    }
    
    private var iconView: some View {
        Image(systemName: icon)
            .font(isHowToPlayButton ? .title2 : .title)
            .foregroundColor(.white)
            .fontWeight(isLeadingIcon ? .regular : .bold)
            .padding(isLeadingIcon ? 23 : geo.size.height/29)
            .frame(minWidth: isLeadingIcon ? nil : geo.size.width/9)
            .background(
                isLeadingIcon ? RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isEnabled ? [.primaryButtonImageBG, .primaryButtonImageBG.opacity(0.8)] : [.black.opacity(0.6), .black.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) : RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.secondaryButtonImageBg, .secondaryButtonImageBg.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: isLeadingIcon ? .clear : Color.black.opacity(0.3), radius: 4, x: 4, y: 4)
    }
    
    private var backgroundColors: [Color] {
        if isLeadingIcon {
            return isEnabled ? [.activeBlue, .activeBlue.opacity(0.8)] : [.gray, .gray.opacity(0.8)]
        } else {
            return [.cardBlue, .cardBlue.opacity(0.8)]
        }
    }
}
