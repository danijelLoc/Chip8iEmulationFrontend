//
//  ContentView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 28.05.2024..
//

import SwiftUI
import Chip8iEmulationCore
import Combine

struct KeyState: Equatable, Identifiable {
    var id: Character { keyboardBinding }
    
    let chip8Key: Chip8Key
    var keyboardBinding: Character
    var pressedDown: Bool = false
}

// TODO: Maybe replace enum operations with commands.

struct Chip8iEmulatorView: View {
    @State private var program: Chip8Program?
    private let loadProgram: Bool
    private let soundHandler: SoundHandlerProtocol?
    
    @State private var savedSoundTimer: UByte = 0
    @State private var savedPlayingInfo: PlayingInfo = .init(hasStarted: false, isPlaying: false)
    
    @State private var pressedKeys: Set<Chip8Key> = []
    
    @State private var emulationCore = Chip8EmulationCore(logger: nil)
    
    init(soundHandler: SoundHandlerProtocol?, loadProgram: Bool = true) {
        self.soundHandler = soundHandler
        self.loadProgram = loadProgram
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Button(action: {
                    Task {
                        if savedPlayingInfo.hasStarted {
                            await emulationCore.stop()
                        } else if let program = program {
                            await emulationCore.emulate(program)
                        }
                    }
                }) {
                    Image(systemName: savedPlayingInfo.hasStarted ? "stop" : "play")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24) // Adjust size as needed
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Button(action: {
                    Task {
                        await emulationCore.togglePause()
                    }
                }) {
                    Image(systemName: savedPlayingInfo.isPlaying ? "pause" : "playpause")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24) // Adjust size as needed
                        .foregroundColor(.white)
                        .padding()
                        .background(savedPlayingInfo.hasStarted ? Color.blue : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(!savedPlayingInfo.hasStarted)
            }
            
            ScreenView(emulationCore: emulationCore)
            
#if os(iOS)
            iOSVirtualControlsView(emulationCore: emulationCore)
#elseif os(macOS)
            macOSKeyboardLayoutView(emulationCore: emulationCore, pressedKeys: $pressedKeys)
#endif
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Fill parent & align to top
        .padding()
        .onAppear(perform: {
            Task {
                program = readProgramFromResource(fileName: "Pong.ch8")
//                let program = Chip8Program.StopwatchExample
                if loadProgram, let program = program {
                    await emulationCore.emulate(program)
                }

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
    }
    
    private func readProgramFromResource(fileName: String) -> Chip8Program {
        guard let fileUrl = Bundle.main.url(forResource: fileName, withExtension: nil)
        else {
            fatalError("Cannot find the program")
        }
        
        guard let data = try? Data(contentsOf: fileUrl)
        else {
            fatalError("Cannot read the program rom byte data")
        }
        
        // print(data.flatMap{String(format:"%02X", $0)})
        let romData = data.compactMap {$0}
        return Chip8Program(name: fileName, contentROM: romData)
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
    Chip8iEmulatorView(soundHandler: nil, loadProgram: false)
}
