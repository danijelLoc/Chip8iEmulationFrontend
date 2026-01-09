//
//  ExecutionMenu.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 09.01.2026..
//

import SwiftUI
import Chip8iEmulationCore


struct ExecutionMenu : View {
    let emulationCore: Chip8EmulationCore
    let selectedRom: Chip8Program?
    let savedPlayingInfo: PlayingInfo
    @Binding var savedState: EmulationState?
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                Task {
                    if savedPlayingInfo.hasStarted {
                        await emulationCore.stop()
                    } else if let selectedRom = selectedRom {
                        await emulationCore.startEmulation(selectedRom)
                    }
                }
            }) {
                Image(
                    systemName: savedPlayingInfo.hasStarted
                        ? "stop" : "play"
                )
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)  // Adjust size as needed
                .foregroundColor(.white)
                .padding()
                .background(
                    selectedRom != nil ? Color.blue : Color.gray
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(selectedRom == nil)
            Button(action: {
                Task {
                    await emulationCore.togglePause()
                }
            }) {
                Image(
                    systemName: savedPlayingInfo.isPlaying
                        ? "pause" : "playpause"
                )
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)  // Adjust size as needed
                .foregroundColor(.white)
                .padding()
                .background(
                    savedPlayingInfo.hasStarted ? Color.blue : Color.gray
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(!savedPlayingInfo.hasStarted)
            
            Button(action: {
                Task {
                    savedState = await emulationCore.exportState()
                }
            }) {
                Image(
                    systemName: "arrow.down.document"
                )
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)  // Adjust size as needed
                .foregroundColor(.white)
                .padding()
                .background(
                    savedPlayingInfo.hasStarted ? Color.blue : Color.gray
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(!savedPlayingInfo.hasStarted)
            Button(action: {
                Task {
                    guard let savedState = savedState else { return }
                    await emulationCore.loadState(savedState)
                }
            }) {
                Image(
                    systemName: "arrow.up.document"
                )
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)  // Adjust size as needed
                .foregroundColor(.white)
                .padding()
                .background(
                    savedPlayingInfo.hasStarted && savedState?.programContentHash == selectedRom?.contentHash  ? Color.blue : Color.gray
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(!savedPlayingInfo.hasStarted || savedState?.programContentHash != selectedRom?.contentHash)
        }
    }
}
