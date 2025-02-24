//
//  Utils.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 24.02.2025..
//
import Foundation
import Chip8iEmulationCore

public class Utils {
    public static func bundledRomUrl(name: String) -> URL? {
        guard let fileUrl = Bundle.main.url(forResource: name, withExtension: nil)
        else { return nil }
        return fileUrl
    }

    public static func loadProgramRom(from url: URL) -> Chip8Program? {
        guard let data = try? Data(contentsOf: url)
        else {
            fatalError("Cannot read the program rom byte data")
        }
        let fileName = url.lastPathComponent
        // print(data.flatMap{String(format:"%02X", $0)})
        let romData = data.compactMap { $0 }
        return Chip8Program(name: fileName, contentROM: romData)
    }
}


