//
//  ContentView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 28.05.2024..
//

import Chip8iEmulationCore
import Combine
import SwiftUI

struct KeyState: Equatable, Identifiable {
    var id: Character { keyboardBinding }

    let chip8Key: Chip8Key
    var keyboardBinding: Character
    var pressedDown: Bool = false
}

struct Chip8iEmulatorView: View {
    let soundHandler: SoundHandlerProtocol?
    
    @Binding var selectedRom: Chip8Program?
    @Binding var recentFiles: Set<URL>
    @Binding var bundledRoms: [String]

    @State private var savedSoundTimer: UByte = 0
    @State private var savedPlayingInfo: PlayingInfo = .init(
        hasStarted: false, isPlaying: false)

    @State private var pressedKeys: Set<Chip8Key> = []
    @State private var emulationCore = Chip8EmulationCore(logger: nil)
    @State private var showGameSelection = false

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Button(action: {
                    Task {
                        if savedPlayingInfo.hasStarted {
                            await emulationCore.stop()
                        } else if let selectedRom = selectedRom {
                            await emulationCore.emulate(selectedRom)
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
            }
            Text("\(selectedRom?.name ?? "Please select game rom")")
                .padding(4)
#if os(iOS)
            Button("Select Game") {
                showGameSelection = true
            }
#elseif os(macOS)
            Text("You can select bundled games or file from disk with macOS menu bar at the top of the screen.")
                .font(.caption)
#endif
            
            ScreenView(emulationCore: emulationCore)

#if os(iOS)
                iOSVirtualControlsView(emulationCore: emulationCore)
#elseif os(macOS)
                macOSKeyboardLayoutView(
                    emulationCore: emulationCore, pressedKeys: $pressedKeys)
#endif

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)  // Fill parent & align to top
        .padding()
        .onAppear(perform: {
            Task {
                // On appear....
            }
        })
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(phases: .down, action: onKeyDown)
        .onKeyPress(phases: .up, action: onKeyUp)
        .onReceive(emulationCore.outputSoundTimerPublisher) { value in
            savedSoundTimer = value
        }
        .onReceive(emulationCore.playingInfoPublisher) { value in
            savedPlayingInfo = value
        }
        .onChange(of: savedSoundTimer) { oldValue, newValue in
            soundHandler?.handleSoundTimerChange(soundTimer: newValue)
        }
        .onChange(of: savedPlayingInfo) { oldValue, newValue in
            soundHandler?.onEmulationPause(isPaused: !newValue.isPlaying)
        }
        .onChange(of: selectedRom) { oldValue, newValue in
            Task {
                if savedPlayingInfo.hasStarted {
                    await emulationCore.stop()
                }
                if let selectedRom = selectedRom {
                    await emulationCore.emulate(selectedRom)
                }
            }
        }
#if os(iOS)
        .sheet(isPresented: $showGameSelection) {
            GameSelectionSheet(isPresented: $showGameSelection, selectedProgram: $selectedRom, recentFiles: $recentFiles, bundledRoms: $bundledRoms)
        }
#endif
    }



    func onKeyDown(key: KeyPress) -> KeyPress.Result {
        guard let chip8Key = Chip8Key.StandardKeyboardBinding[key.key.character]
        else { return .ignored }

        pressedKeys.insert(chip8Key)

        emulationCore.onKeyDown(chip8Key)
        return .handled
    }

    func onKeyUp(key: KeyPress) -> KeyPress.Result {
        guard let chip8Key = Chip8Key.StandardKeyboardBinding[key.key.character]
        else { return .ignored }

        pressedKeys.remove(chip8Key)

        emulationCore.onKeyUp(chip8Key)
        return .handled
    }
}

#Preview {
}
