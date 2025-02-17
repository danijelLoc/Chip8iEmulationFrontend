//
//  macOSKeyboardLayoutView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 15.02.2025..
//

import SwiftUI
import Chip8iEmulationCore


struct macOSKeyboardLayoutView: View {
    @Binding private var usedKeys: Set<UByte>?
    @Binding private var pressedKeys: Set<Chip8Key>
    
    var body: some View {
        VStack {
            Text("Chip-8 Keyboard Layout")
                .font(.headline)
            Grid {
                ForEach(Chip8Key.StandardLayout, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { chip8key in
                            let keyboardKey: Character = Chip8Key.StandardKeyboardBinding.KeyFromValue(chip8key) ?? "?"
                            let foregroundColor: Color = usedKeys?.contains(chip8key.rawValue) == true ? .white : .gray
                            VStack {
                                Text("chip8: " + chip8key.label)
                                    .font(.footnote.italic())
                                Text(String(keyboardKey))
                                    .font(.title2)
                            }
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                            .background(pressedKeys.contains(chip8key) ? Color.blue : Color.blue.opacity(0.5))
                            .border(foregroundColor, width: 2)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
