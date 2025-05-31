//
//  GeneratedSoundHandler.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 15.02.2025..
//

import AVFoundation
import Chip8iEmulationCore

/// In experimental phase, short beep is not working... please use PrerecordedSoundHandler from Chip8iEmulationCore
public class GeneratedSoundHandler: SoundHandlerProtocol {
    private var audioEngine: AVAudioEngine?
    private var beepPlayerNode: AVAudioPlayerNode?
    private var beepBuffer: AVAudioPCMBuffer?
    
    private let beepFrequency: Float = 1000 // Frequency of the beep in Hz
    private let beepShortestDuration: Float = 0.1
    
    private var isEmulationPaused = false
    
    init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        beepPlayerNode = AVAudioPlayerNode()
        
        // Create a buffer with the appropriate duration and frequency
        beepBuffer = createBeepBuffer(frequency: beepFrequency, duration: beepShortestDuration)
        
        // Attach player node to the audio engine
        if let beepPlayerNode = beepPlayerNode {
            audioEngine!.attach(beepPlayerNode)
            audioEngine!.connect(beepPlayerNode, to: audioEngine!.mainMixerNode, format: beepBuffer!.format)
        }
        
        // Start the audio engine
        do {
            try audioEngine!.start()
            beepPlayerNode?.scheduleBuffer(beepBuffer!, at: nil, options: .loops, completionHandler: nil)
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    private func createBeepBuffer(frequency: Float, duration: Float) -> AVAudioPCMBuffer? {
        let sampleRate: Float = 44100.0
        guard let buffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)!, frameCapacity: AVAudioFrameCount(sampleRate * duration))
        else { return nil }
        
        buffer.frameLength = buffer.frameCapacity
        let thetaIncrement = 2.0 * Float.pi * frequency / sampleRate
        
        var sample: Float = 0.0
        var theta: Float = 0.0
        
        for frame in 0..<Int(buffer.frameLength) {
            sample = sin(theta)
            buffer.floatChannelData?.pointee[frame] = sample
            theta += thetaIncrement
            if theta > 2.0 * Float.pi {
                theta -= 2.0 * Float.pi
            }
        }
        
        return buffer
    }
    
    public func handleSoundTimerChange(soundTimer: UInt8) {
        if isEmulationPaused {
            beepPlayerNode?.pause()
            return
        }
        
        if soundTimer > 0 {
            // Start the beep sound if it's not playing already
            if beepPlayerNode?.isPlaying == false {
                beepPlayerNode?.play()
            }
        } else {
            // Stop the beep sound if the timer is 0
            beepPlayerNode?.stop()
            beepPlayerNode?.scheduleBuffer(beepBuffer!, at: nil, options: .loops, completionHandler: nil)
        }
    }
    
    public func onEmulationPause(isPaused: Bool) {
        isEmulationPaused = isPaused
    }
}
