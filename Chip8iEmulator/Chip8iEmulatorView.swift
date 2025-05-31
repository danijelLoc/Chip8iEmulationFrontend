//
//  ContentView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 28.05.2024..
//

import Chip8iEmulationCore
import SwiftUI

struct KeyState: Equatable, Identifiable {
    var id: Character { keyboardBinding }

    let chip8Key: Chip8Key
    var keyboardBinding: Character
    var pressedDown: Bool = false
}

struct Chip8iEmulatorView: View {
    
    @Binding var selectedRom: Chip8Program?
    @Binding var recentFiles: Set<URL>
    @Binding var bundledRoms: [String]

    @State private var savedState: EmulationState? = nil
    
    @State private var savedPlayingInfo: PlayingInfo = .init(
        hasStarted: false, isPlaying: false)

    @State private var pressedKeys: Set<Chip8Key> = []
    @State private var emulationCore = Chip8EmulationCore(
        soundHandler: PrerecordedSoundHandler(with: "Beep2.wav"), logger: nil)
    
    @State private var showingMenuSheet = false
    
    var body: some View {
        VStack {
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
            Text("\(selectedRom?.name ?? "Please select game rom")")
                .padding(4)
#if os(iOS)
            Button("Menu") {
                showingMenuSheet = true
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
        .padding(4)
        .onAppear(perform: {
            Task {
                // On appear....
            }
        })
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(phases: .down, action: onKeyDown)
        .onKeyPress(phases: .up, action: onKeyUp)
        .onChange(of: emulationCore.playingInfo) { oldValue, newValue in
            savedPlayingInfo = newValue
        }
        .onChange(of: selectedRom) { oldValue, newValue in
            Task {
                if savedPlayingInfo.hasStarted {
                    await emulationCore.stop()
                }
                if let selectedRom = selectedRom {
                    await emulationCore.startEmulation(selectedRom)
                }
            }
        }
        .onChange(of: showingMenuSheet) { isPresentedOld, isPresentedNew in
            Task {
                if !(isPresentedNew == true && !savedPlayingInfo.isPlaying) && savedPlayingInfo.hasStarted {
                    await emulationCore.togglePause()
                }
            }
        }
#if os(iOS)
        .sheet(isPresented: $showingMenuSheet) {
            iOSMenuSheetView(isPresented: $showingMenuSheet, selectedProgram: $selectedRom, recentFiles: $recentFiles, bundledRoms: $bundledRoms)
        }
#endif
    }



    func onKeyDown(key: KeyPress) -> KeyPress.Result {
        guard let chip8Key = Chip8Key.StandardKeyboardBinding[key.key.character]
        else { return .ignored }
        pressedKeys.insert(chip8Key)
        
        Task {
            await emulationCore.onKeyDown(chip8Key)
        }
        return .handled
    }

    func onKeyUp(key: KeyPress) -> KeyPress.Result {
        guard let chip8Key = Chip8Key.StandardKeyboardBinding[key.key.character]
        else { return .ignored }
        pressedKeys.remove(chip8Key)
        
        Task {
            await emulationCore.onKeyUp(chip8Key)
        }

        return .handled
    }
}

#Preview {
    @Previewable @State var selectedRom: Chip8Program? = nil
    @Previewable @State var recentFiles: Set<URL> = []
    @Previewable @State var bundledRoms = [String]()
    
    Chip8iEmulatorView(selectedRom: $selectedRom, recentFiles: $recentFiles, bundledRoms: $bundledRoms)
}
