//
//  macOSKeyboardLayoutView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 15.02.2025..
//

import SwiftUI
import Chip8iEmulationCore


struct macOSKeyboardLayoutView: View {
    public var emulationCore: Chip8EmulationCore
    @Binding public var pressedKeys: Set<Chip8Key>
    @State private var requiredKeys: Set<UByte> = []
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Play with the Keyboard, this is mapping layout")
                .font(.subheadline)
                .padding(4)
            ForEach(Chip8Key.StandardLayout, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { chip8key in
                        let keyboardKey: Character = Chip8Key.StandardKeyboardBinding.KeyFromValue(chip8key) ?? "?"
                        let foregroundColor: Color = requiredKeys.contains(chip8key.rawValue) == true ? .white : .white.opacity(0.7)
                        let backgroundColor: Color = pressedKeys.contains(chip8key) ? Color.blue.opacity(0.5) : Color.blue
                        
                        Button(action: {
                        }) {
                            VStack {
                                Text("chip8: " + chip8key.label)
                                    .font(.footnote.italic())
                                Text(String(keyboardKey))
                                    .font(.title2)
                            }
                            .frame(width: 60, height: 60)
                            .foregroundColor(foregroundColor)
                            .background(backgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .onLongPressGesture(
                            minimumDuration: 0.01, maximumDistance: 10,
                            perform: {
                                Task {
                                    await emulationCore.onKeyUp(chip8key)
                                }
                            },
                            onPressingChanged: {state in
                                Task {
                                    if state {
                                        await emulationCore.onKeyDown(chip8key)
                                        
                                    } else {
                                        await emulationCore.onKeyUp(chip8key)
                                    }
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .onChange(of: emulationCore.debugSystemState?.requiredKeysHelper) { oldKeys, newKeys in
            // Map the required keys from the system state
            guard let keys = newKeys else { return }
            requiredKeys = keys
        }
    }
}
