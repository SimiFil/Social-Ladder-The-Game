//
//  ContentView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI

struct MainPage: View {
    @State private var animationOffset: CGFloat = -1.0
    
    @State private var isMusicDisabled: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.customWhitesmoke
                    .ignoresSafeArea()
                
                HStack {
                    VStack {
                        Text("The Social Ladder")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Image(systemName: "person.3.fill")
                            .imageScale(.large)
                            .font(.system(size: 80))
                            .foregroundColor(.black)
                    }
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            // action -> go to connect lobby
                        }) {
                            Text("Play")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.white)
                                )
                                .foregroundColor(.black)
                                .shadow(color: .gray.opacity(0.5), radius: 4, x: 2, y: 2)
                        }
                        
                        Button(action: {
                            // action -> go to the about page/sheet
                        }) {
                            Text("Settings")
                                .font(.title2)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.white)
                                )
                                .foregroundColor(.black)
                                .shadow(color: .gray.opacity(0.5), radius: 4, x: 2, y: 2)
                        }
                        
                        Button(action: {
                            // action -> go to the about page/sheet
                        }) {
                            Text("About")
                                .font(.title2)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.white)
                                )
                                .foregroundColor(.black)
                                .shadow(color: .gray.opacity(0.5), radius: 4, x: 2, y: 2)
                        }
                    }
                    .padding(.horizontal, 100)
                }
            }
            .toolbar {
                // Toolbar: App Title
                // FIXME: add url to instagram perhaps
                ToolbarItem(placement: .topBarLeading) {
                    Text("@\(Constants.gameName.removeSpaces())")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 25)
                }
                
                // Toolbar: Disable Music Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isMusicDisabled.toggle()
                    } label: {
                        Image(systemName: isMusicDisabled ? "speaker.slash.fill" : "speaker.wave.3.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                            .padding(.top, 25)
                            .animation(.default, value: isMusicDisabled)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    // change to picker
                    Button {
                        isMusicDisabled.toggle()
                    } label: {
                        Image(systemName: "globe")
                            .foregroundColor(.gray)
                            .font(.title2)
                            .padding(.top, 25)
                            .animation(.default, value: isMusicDisabled)
                    }
                }
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    MainPage()
}
