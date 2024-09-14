//
//  ContentView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 28.05.2024..
//

import SwiftUI
import AppKit
import Chip8iEmulationCore

struct Chip8iEmulatorView: View {
    @StateObject var emulationCore = Chip8EmulationCore()
    private let singlePingSound = NSSound(named: NSSound.Name("Ping"))

    var body: some View {
        VStack {
            Image(CGImage.fromMonochromeBitmap(emulationCore.outputScreen, width: 64, height: 32)!, scale: 5, label: Text("Output"))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
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
        emulationCore.onKeyDown(key: key.key.character)
        return .handled
    }
    
    func onKeyUp(key: KeyPress) -> KeyPress.Result {
        emulationCore.onKeyUp(key: key.key.character)
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



#Preview {
    Chip8iEmulatorView()
}

