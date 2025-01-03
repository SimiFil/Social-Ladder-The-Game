//
//  SelectGameModeView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI

struct SelectGameModeView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.darkNavy, Color.darkNavy.opacity(0.95)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                HStack(spacing: 50) {
                    ForEach(0..<2, id: \.self) { id in
                        ZStack(alignment: .center) {
                            // Card background
                            Color.cardBlue
                                .font(.title2)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.cardBlue)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.activeBlue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                                .padding(.top)
                            
                            VStack(alignment: .center) {
                                Image(systemName: id == 0 ? "house.fill" : "wifi.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                                    .shadow(color: Color.activeBlue.opacity(0.5), radius: 10, x: 0, y: 0)
                                
                                Text(id == 0 ? "LOCAL" : "ONLINE")
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                            .padding(.top)
                            .minimumScaleFactor(0.5)
                        }
                        .onTapGesture {
                            print("click")
                        }
                    }
                }
                .ignoresSafeArea()
                .padding(50)
                .background(Color.darkNavy)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
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
                                            .stroke(Color.activeBlue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                            .padding(.top, 50)
                            .font(.title2)
                            .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview(traits: .landscapeRight) {
    SelectGameModeView()
}
