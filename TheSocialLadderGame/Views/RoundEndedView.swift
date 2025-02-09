//
//  RoundEndedView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 27.01.2025.
//

import SwiftUI

struct RoundEndedView: View {
   @ObservedObject var gameManager: GameManager
   
   var body: some View {
       GeometryReader { geo in
           VStack(spacing: 20) {
               VStack(alignment: .center) {
                   if gameManager.chosenPlayerID == gameManager.localPlayer.gamePlayerID {
                       Text("MY ORDER")
                           .font(.headline)
                           .padding(.bottom, 2)
                   } else {
                       Text("CHOSEN PLAYER'S ORDER")
                           .font(.headline)
                           .padding(.bottom, 2)
                   }
                   
                   HStack(spacing: 15) {
                       ForEach(Array(gameManager.chosenPlayerOrder.enumerated()), id: \.offset) { _, name in
                          PlayerBox(name: name)
                       }
                   }
               }
               .padding(.horizontal)
               .padding(.top)
               
               
               if gameManager.chosenPlayerID != gameManager.localPlayer.gamePlayerID {
                   VStack(alignment: .center) {
                       Text("MY ORDER")
                           .font(.headline)
                           .padding(.bottom, 2)
                       
                       HStack(spacing: 15) {
                           ForEach(Array(zip(gameManager.playerCardsOrder, gameManager.calculatePoints()).enumerated()), id: \.element.0) { _, element in
                              PlayerBox(name: element.0, score: element.1)
                           }
                           
                           if let myScore = gameManager.playerScoreDict[gameManager.localPlayer.displayName]?.last,
                                myScore > gameManager.players.count {
                               ZStack(alignment: .center) {
                                   Image(systemName: "star")
                                       .font(.largeTitle)
                                       .fontWeight(.bold)
                                       .imageScale(.large)
                                   
                                   Text("+1")
                                       .font(.body)
                               }
                               .foregroundStyle(.yellow)
                               .foregroundStyle(.yellow)
                           }
                       }
                   }
                   .padding(.horizontal)
               }
           }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
           .padding()
           .padding(.horizontal)
       }
       .onAppear {
           gameManager.startRoundTimer(time: Constants.talkingTime)
       }
   }
}

struct PlayerBox: View {
   let name: String
   var score: String?
   
   var body: some View {
       ZStack {
           RoundedRectangle(cornerRadius: 10)
               .fill(
                   LinearGradient(
                       colors: [Color.cardBlue.opacity(0.6), Color.ultraLightBlue.opacity(0.8)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing
                   )
               )
               .shadow(radius: 2)
           
           VStack {
               if let score = score {
                   HStack {
                       Spacer()
                       Text(score)
                           .font(.caption)
                           .foregroundColor(.customWhitesmoke)
                           .fontWeight(.bold)
                           .padding(15)
                           .background(
                               Circle()
                                   .fill(score == "1" || score == "+" ? .green : .red)
                                   .shadow(radius: 1)
                           )
                           .offset(x: 20, y: -40)
                   }
               }
           }
           .padding(8)
           
           VStack {
               Spacer()
               
               Text(name == " " ? "Nothing" : name)
                   .font(.body)
                   .foregroundStyle(.white)
                   .fontWeight(.medium)
                   .lineLimit(2)
                   .multilineTextAlignment(.center)
                   .minimumScaleFactor(0.8)
               
               Spacer()
           }
       }
       .frame(width: 80, height: 100)
   }
}

#Preview(traits: .landscapeRight) {
    RoundEndedView(gameManager: GameManager())
}
