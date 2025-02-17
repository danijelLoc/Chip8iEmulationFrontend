//
//  iOSVirtualControlsView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 15.02.2025..
//

import SwiftUI
import Chip8iEmulationCore

struct iOSVirtualControlsView: View {
    @ObservedObject public var emulationCore: Chip8EmulationCore
    
//    @ObservedObject public var usedKeys: Set<UByte>
    @ObservedObject public var systemState: Chip8SystemState
    
    
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
                                .foregroundColor(systemState.UsedKeysHelper.contains(key.rawValue) == true ? .white : .white.opacity(0.7))
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
    }
}
