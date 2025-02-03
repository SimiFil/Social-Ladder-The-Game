//
//  SettingsView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 20.01.2025.
//

import SwiftUI
import AVKit

enum SettingsKeys {
    static let volume = "appVolume"
    static let language = "selectedLanguage"
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var audioPlayer: AVAudioPlayer
    @Binding var volume: Float
    
    @AppStorage(SettingsKeys.language) private var selectedLanguage = "eng"
    let languages = [
        "eng": "English",
        "cz": "Čeština",
        "spa": "Español",
        "de": "Deutsch"
    ]
    
    private let defaults = UserDefaults.standard
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppBackground()
                
                VStack(alignment: .center, spacing: 32) {
                    HStack {
                        GoBackButton()
                            .padding(.leading, -geo.size.width/60)
                        
                        Spacer()
                        
                        HStack {
                            Text("Settings")
                                
                            Image(systemName: "gear")
                        }
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, geo.size.width/30)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: Audio Settings
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Audio")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 16) {
                                Image(systemName: "speaker.wave.3")
                                    .foregroundColor(.white)
                                
                                VolumeSlider(volume: $volume) { newVolume in
                                    audioPlayer.volume = newVolume
                                    defaults.set(newVolume, forKey: SettingsKeys.volume)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // MARK: Language Settings
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Language")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Select Language", selection: $selectedLanguage) {
                                ForEach(Array(languages.keys.sorted(by: { $0 > $1 })), id: \.self) { key in
                                    Text(languages[key] ?? key)
                                        .onTapGesture {
                                            defaults.set(selectedLanguage, forKey: "selectedLanguage")
                                        }
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            volume = defaults.float(forKey: SettingsKeys.volume)
            audioPlayer.volume = volume
            selectedLanguage = defaults.string(forKey: SettingsKeys.language) ?? "eng"
        }
    }
}

struct VolumeSlider: View {
    @Binding var volume: Float
    let onChanged: (Float) -> Void
    
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: geo.size.width, height: 4)
                    .cornerRadius(2)
                
                // Volume level indicator
                Rectangle()
                    .fill(Color.white)
                    .frame(width: CGFloat(volume) * geo.size.width, height: 4)
                    .cornerRadius(2)
                
                // Draggable circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .position(x: CGFloat(volume) * geo.size.width, y: geo.size.height/2)
                    .shadow(radius: isDragging ? 4 : 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDragging = true
                                let newVolume = Float(min(max(0, value.location.x), geo.size.width)) / Float(geo.size.width)
                                volume = newVolume
                                onChanged(newVolume)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
        }
        .frame(height: 50)
    }
}

#Preview(traits: .landscapeRight) {
    SettingsView(
        audioPlayer: try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "lobbyMusic", withExtension: "mp3")!),
        volume: .constant(0.5)
    )
}
