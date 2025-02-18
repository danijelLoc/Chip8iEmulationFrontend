//
//  iOSVirtualControlsView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 15.02.2025..
//

import SwiftUI
import Chip8iEmulationCore

struct iOSVirtualControlsView: View {
    var emulationCore: Chip8EmulationCore
    @State private var requiredKeys: Set<UByte> = []
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(Chip8Key.StandardLayout, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button(action: {
                        }) {
                            Text(key.label)
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .foregroundColor(requiredKeys.contains(key.rawValue) == true ? .white : .white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .onLongPressGesture(
                            minimumDuration: 0.01, maximumDistance: 10,
                            perform: {
                                emulationCore.onKeyUp(key)
                            },
                            onPressingChanged: {state in
                                if state {
                                    emulationCore.onKeyDown(key)
                                } else {
                                    emulationCore.onKeyUp(key)
                                }
                                
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .onReceive(emulationCore.debugSystemStateInfoPublisher) { systemState in
            // Map the required keys from the system state
            requiredKeys = systemState.requiredKeysHelper
        }
    }
}
