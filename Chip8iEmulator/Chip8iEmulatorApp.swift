//
//  Chip8iEmulatorApp.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 28.05.2024..
//

import SwiftUI
import Chip8iEmulationCore

@main
struct Chip8iEmulatorApp: App {
    @State private var selectedRom: Chip8Program?
    @State private var recentFiles: Set<URL> = []
    @State private var bundledRoms = [
        "SpaceInvaders.ch8",
        "Breakout.ch8",
        "Pong.ch8",
        "Tic-Tac-Toe.ch8",
        "Pong (1 player).ch8"
    ]
    
    var body: some Scene {
        WindowGroup {
            Chip8iEmulatorView(selectedRom: $selectedRom, recentFiles: $recentFiles, bundledRoms: $bundledRoms)
        }
        .commands {
#if os(macOS)
        macOSToolbarCommands(selectedProgram: $selectedRom, recentFiles: $recentFiles, bundledRoms: $bundledRoms)
#endif
        }
    }
}
