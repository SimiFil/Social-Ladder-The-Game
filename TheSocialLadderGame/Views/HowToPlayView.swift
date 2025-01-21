//
//  HowToPlayView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 20.01.2025.
//

import SwiftUI

struct HowToPlayView: View {
    // FIXME: replace colors with images desplaying how to play the game
    @State var colors: [Color] = [.yellow, .orange, .red, .cyan]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppBackground()
                
                // MARK: How to play slider
                VStack(alignment: .trailing, spacing: 1) {
                    HStack(alignment: .center) {
                        GoBackButton()
                            .padding(.leading, geo.size.width/15)
                        
                        Spacer()
                        
                        HStack {
                            Text("How To Play")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Image(systemName: "gamecontroller.fill")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .imageScale(.medium)
                                .rotationEffect(Angle(degrees: 45))
                        }
                        .padding(.trailing, geo.size.width/15)
                    }
                    .foregroundStyle(.white)
                    .padding(.top, geo.size.width/30)
                    .padding(.bottom, -geo.size.height/25)
                    
                    TabView {
                        ForEach(colors, id: \.self) { color in
                            Text("hi")
                                .frame(minWidth: geo.size.width/1.15, minHeight: geo.size.height/1.5)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(color)
                                }
                        }
                        
                    }
                    .tabViewStyle(.page)
                    .frame(width: geo.size.width, height: geo.size.height/1.1)
                    .clipShape(.rect(cornerRadius: 25))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview(traits: .landscapeLeft) {
    HowToPlayView()
}
