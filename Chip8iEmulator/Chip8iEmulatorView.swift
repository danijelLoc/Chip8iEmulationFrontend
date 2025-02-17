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
    
    @State private var fps: Double = 0
    @State private var frameTimes: [Double] = []
    @State private var lastFrameUpdate: Date?
    @State private var lastFrame: [Bool] = Array(repeating: false, count: 64*32)
    
    @State private var pressedKeys: Set<Chip8Key> = []
    
    private var emulationCore = Chip8EmulationCore(logger: nil)
    
    init(soundHandler: SoundHandlerProtocol?, loadProgram: Bool = true) {
        self.soundHandler = soundHandler
        self.loadProgram = loadProgram
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Button(action: {
                    Task {
                        if emulationCore.playingInfo.hasStarted {
                            await emulationCore.stop()
                        } else if let program = program {
                            await emulationCore.emulate(program)
                        }
                    }
                }) {
                    Image(systemName: emulationCore.playingInfo.hasStarted ? "stop" : "play")
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
                    Image(systemName: emulationCore.playingInfo.isPlaying ? "pause" : "playpause")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24) // Adjust size as needed
                        .foregroundColor(.white)
                        .padding()
                        .background(emulationCore.playingInfo.hasStarted ? Color.blue : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(!emulationCore.playingInfo.hasStarted)
            }
            
            Text(String(format: "FPS: %.2f", fps))
                  .font(.headline)
                  .padding()
            Image(CGImage.fromMonochromeBitmap(lastFrame, width: 64, height: 32)!, scale: 1, label: Text("Output")
            )
                .interpolation(.none)
                .resizable()
                .aspectRatio(64.0 / 32.0, contentMode: .fit)
                .frame(minWidth: 64*3, minHeight: 32*3)
                .background(Color.red)
                .padding(10)
            
            if let errorInfo = emulationCore.debugErrorInfo {
                Text("Halted by error - " + errorInfo.localizedDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
            }
            
#if os(iOS)
            iOSVirtualControlsView(emulationCore: emulationCore, systemState: emulationCore.debugSystemStateInfo)
#elseif os(macOS)
//            macOSKeyboardLayoutView(emulationCore: emulationCore, pressedKeys: pressedKeys)
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
        .onChange(of: emulationCore.outputSoundTimer) { oldValue, newValue in
            soundHandler?.handleSoundTimerChange(soundTimer: newValue)
        }
        .onChange(of: emulationCore.playingInfo.isPlaying) { oldValue, newValue in
            soundHandler?.onEmulationPause(isPaused: !newValue)
        }
        .onReceive(emulationCore.outputScreenPublisher) { frame in
            self.lastFrame = frame
            
            guard let lastFrameUpdate = lastFrameUpdate else {
                self.lastFrameUpdate = Date()
                return
            }
            
            let now = Date()
            let frameTime = now.timeIntervalSince(lastFrameUpdate)
            
            if frameTimes.count == 60 {
                frameTimes.removeFirst()
            }
            
            frameTimes.append(frameTime)
            let avgFrameTime = frameTimes.reduce(0, +) / Double(frameTimes.count)
            fps = 1.0 / avgFrameTime // TODO: Move to CORE DEBUG PUBLISHER !!!!

            self.lastFrameUpdate = now
        }
        .onChange(of: emulationCore.debugSystemStateInfo) { oldeValue, newValue in
            var usedKeys = newValue.UsedKeysHelper
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
        
        emulationCore.onKeyDown(chip8Key)
        return .handled
    }
    
    func onKeyUp(key: KeyPress) -> KeyPress.Result {
        guard let chip8Key = Chip8Key.StandardKeyboardBinding[key.key.character]
        else { return .ignored }
        
        emulationCore.onKeyUp(chip8Key)
        return .handled
    }
}


#Preview {
    Chip8iEmulatorView(soundHandler: nil, loadProgram: false)
}
