//
//  PrerecordedSoundHandler.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 15.02.2025..
//

import Chip8iEmulationCore
import AVFoundation

public class PrerecordedSoundHandler: SoundHandlerProtocol {
    private var audioPlayer: AVAudioPlayer?
    private var isEmulationPaused: Bool = false
    
    public init() {
        loadSound()
    }
    
    private func loadSound() {
        guard let soundURL = Bundle.main.url(forResource: "Beep2", withExtension: "wav") else {
            print("Failed to locate sound file")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1  // Loop indefinitely
        } catch {
            print("Error loading sound: \(error)")
        }
    }
    
    public func handleSoundTimerChange(soundTimer: UInt8) {
        if isEmulationPaused {
            audioPlayer?.pause()
            return
        }
        
        if soundTimer > 0 && !(audioPlayer?.isPlaying == true) {
            audioPlayer?.play()
        } else if soundTimer == 0 && audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }
    }
    
    public func onEmulationPause(isPaused: Bool) {
        isEmulationPaused = isPaused
    }
}
