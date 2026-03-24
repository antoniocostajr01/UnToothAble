//
//  AudioManager.swift
//  UnToothAble
//
//  Created by Antonio Costa on 20/03/26.
//

import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var targetMusicVolume: Float = 0.5

    var isMuted = false
    
    var player: AVAudioPlayer?      // Música de fundo (Loops longos)
    
    func playMusic(named fileName: String, volume: Float = 0.5) {
            targetMusicVolume = volume
            
            guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
                print("Audio file not found.")
                return
            }
            
            if let player = player, player.url == url, player.isPlaying {
                return
            }
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1 // Loop infinito para música de fundo
                player?.volume = isMuted ? 0 : targetMusicVolume
                player?.prepareToPlay()
                player?.play()
            } catch {
                print("Error trying to play audio: \(error.localizedDescription)")
            }
            
        }
    
    func toggleMute() {
        isMuted.toggle()
        player?.volume = isMuted ? 0 : targetMusicVolume
    }
}
