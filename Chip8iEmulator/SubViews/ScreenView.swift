//
//  ScreenView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 17.02.2025..
//
import SwiftUI
import Chip8iEmulationCore

public struct ScreenView: View {
    let emulationCore: Chip8EmulationCore
    
    public var body: some View {
        VStack {
            Text(String(format: "FPS: %.2f", self.emulationCore.outputScreen.fps))
                  .font(.headline)
                  .padding(4)
            Image(CGImage.fromMonochromeBitmap(self.emulationCore.outputScreen.screen, width: 64, height: 32)!, scale: 1, label: Text("Output")
            )
                .interpolation(.none)
                .resizable()
                .aspectRatio(64.0 / 32.0, contentMode: .fit)
                .frame(minWidth: 64*3, minHeight: 32*3)
                .background(Color.red)
                .padding(4)
            
//            if let errorInfo = debugErrorInfo {
//                Text("Halted by error - " + errorInfo.localizedDescription)
//                    .font(.system(size: 12))
//                    .foregroundStyle(.red)
//            }
        }
    }
}
