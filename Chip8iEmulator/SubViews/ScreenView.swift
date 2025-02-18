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
    
    @State private var fps: Double = 0
    @State private var frameTimes: [Double] = []
    @State private var lastFrameUpdate: Date?
    @State private var lastFrame: [Bool] = Array(repeating: false, count: 64*32)
//    @Binding public var debugErrorInfo: Error?
    
    public var body: some View {
        VStack {
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
            
//            if let errorInfo = debugErrorInfo {
//                Text("Halted by error - " + errorInfo.localizedDescription)
//                    .font(.system(size: 12))
//                    .foregroundStyle(.red)
//            }
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
    }
}
