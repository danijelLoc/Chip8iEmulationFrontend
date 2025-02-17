//
//  SoundHandler.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 15.02.2025..
//

import Chip8iEmulationCore

public protocol SoundHandlerProtocol {
    func handleSoundTimerChange(soundTimer: UByte)
    func onEmulationPause(isPaused: Bool)
}
