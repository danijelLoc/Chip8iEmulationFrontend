//
//  ContentView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 28.05.2024..
//

import SwiftUI
import AppKit
import Chip8iEmulationCore

struct KeyState: Equatable, Identifiable {
    var id: Character { keyboardBinding }
    
    let chip8Key: EmulationControls.Chip8Key
    var keyboardBinding: Character
    var pressedDown: Bool = false
}

struct Chip8iEmulatorView: View {
    @StateObject var emulationCore = Chip8EmulationCore(logger: .none)
    private let singlePingSound = NSSound(named: NSSound.Name("Ping"))

    @State private var keyStates: [KeyState] = [
        KeyState(chip8Key: .One, keyboardBinding: "1"),
        KeyState(chip8Key: .Two, keyboardBinding: "2"),
        KeyState(chip8Key: .Three, keyboardBinding: "3"),
        KeyState(chip8Key: .C, keyboardBinding: "4"),
        KeyState(chip8Key: .Four, keyboardBinding: "q"),
        KeyState(chip8Key: .Five, keyboardBinding: "w"),
        KeyState(chip8Key: .Six, keyboardBinding: "e"),
        KeyState(chip8Key: .D, keyboardBinding: "r"),
    ]
    
    var body: some View {
        VStack {
            Image(CGImage.fromMonochromeBitmap(emulationCore.outputScreen, width: 64, height: 32)!, scale: 500, label: Text("Output")
            )
                .interpolation(.none)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 640, minHeight: 320)

            // Create rows of keys
            ForEach(0..<2, id: \.self) { rowIndex in
                HStack {
                    ForEach(0..<4, id: \.self) { colIndex in
                        let keyIndex = rowIndex * 4 + colIndex
                        let key = keyStates[keyIndex]
                        
                        NumberButtonView(character: key.keyboardBinding, chipKey: key.chip8Key,
                                         onPress: {
                            keyStates[keyIndex].pressedDown = true
                        }, onRelease: {
                            keyStates[keyIndex].pressedDown = false
                        }, isPressed: .constant(keyStates[keyIndex].pressedDown))
                        
                    }
                }
            }
        }
        .padding()
        .onAppear(perform: {
            Task {
                let program = readProgramFromFile(fileName: "Pong.ch8")
                await emulationCore.emulate(program: program)
            }
        })
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(phases: .down, action: onKeyDown)
        .onKeyPress(phases: .up, action: onKeyUp)
        .onChange(of: keyStates) { oldValue, newValue in
            for i in 0..<newValue.count {
                let newKeyState: KeyState = newValue[i]
                if newValue[i].pressedDown {
                    emulationCore.onKeyDown(key: newKeyState.chip8Key)
                }
            }
        }
        .onChange(of: emulationCore.outputSoundTimer) { oldValue, newValue in
            handleSoundTimerChange(soundTimer: newValue)
        }

    }
    
    private func readProgramFromFile(fileName: String) -> Chip8Program {
        guard let fileUrl = Bundle.main.url(forResource: fileName, withExtension: nil)
        else { fatalError("Cannot find the program") }
        
        guard let data = try? Data(contentsOf: fileUrl)
        else { fatalError("Cannot read the program rom byte data") }
        
        // print(data.flatMap{String(format:"%02X", $0)})
        let romData = data.compactMap {$0}
        return Chip8Program(name: fileName, contentROM: romData)
    }
    
    func onKeyDown(key: KeyPress) -> KeyPress.Result {
        guard let chip8Key: EmulationControls.Chip8Key = keyStates.first(where: { k in
            k.keyboardBinding == key.key.character
        })?.chip8Key else { return .ignored }
        emulationCore.onKeyDown(key: chip8Key)
        return .handled
    }
    
    func onKeyUp(key: KeyPress) -> KeyPress.Result {
        guard let chip8Key: EmulationControls.Chip8Key = keyStates.first(where: { k in
            k.keyboardBinding == key.key.character
        })?.chip8Key else { return .ignored }
        emulationCore.onKeyUp(key: chip8Key)
        return .handled
    }
    
    func handleSoundTimerChange(soundTimer: UByte) {
        if soundTimer > 0 && !(singlePingSound?.isPlaying == true) {
            singlePingSound?.play()
        } else if soundTimer == 0 && singlePingSound?.isPlaying == true {
            singlePingSound?.stop()
        }
    }
}

struct NumberButtonView: View {
    let character: Character
    let chipKey: EmulationControls.Chip8Key
    let onPress: () -> Void
    let onRelease: () -> Void
    @Binding var isPressed: Bool

    var body: some View {
        Button(action: {
            //onPress()
        }) {
            Text(String(character))
                .font(.caption)
                .padding()
                .frame(width: 60, height: 60)
                .background(isPressed ? Color.green : Color.gray) // Change background on press
                .cornerRadius(8)
                .foregroundColor(isPressed ? Color.white : Color.black) // Change text color if pressed
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
            .onChanged { _ in
                onPress()
            }.onEnded { _ in
                onRelease()
            }
        )
    }
}


#Preview {
    Chip8iEmulatorView()
}

