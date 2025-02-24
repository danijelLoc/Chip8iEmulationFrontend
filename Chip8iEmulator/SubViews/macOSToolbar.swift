//
//  macOSToolbar.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 24.02.2025..
//

import SwiftUI
import Chip8iEmulationCore
import AppKit

struct macOSToolbarCommands: Commands {
    @Binding var selectedProgram: Chip8Program?
    @Binding var recentFiles: Set<URL>
    @Binding var bundledRoms: [String]
    
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Select ROM from ch8 file...") {
                showOpenPanel()
            }

            Divider()

            // Submenu for "Recent Files"
            Menu("Recent Files") {
                // Dynamically create menu items for recent files
                ForEach(Array(recentFiles), id: \.self) { file in
                    Button(file.lastPathComponent) {
                        selectRom(fileUrl: file)
                    }
                }
                Divider()
                Button("Clear Recent") {
                    recentFiles.removeAll()
                }
            }

            Menu("Bundled Games") {
                ForEach(bundledRoms, id: \.self) { gameName in
                    Button(gameName) {
                        selectRom(bundle: gameName)
                    }
                }
            }
        }
    }

    func loadRecentFiles() {
        if let savedFiles = UserDefaults.standard.array(forKey: "recentFiles") as? [URL] {
            recentFiles = Set(savedFiles)
        }
    }
    
    func selectRom(bundle: String) {
        guard let fileUrl = Utils.bundledRomUrl(name: bundle) else { return }
        let program = Utils.loadProgramRom(from: fileUrl)
        selectedProgram = program
    }
    
    func selectRom(fileUrl: URL) {
        let program = Utils.loadProgramRom(from: fileUrl)
        recentFiles.insert(fileUrl)
        selectedProgram = program
    }

    
    func showOpenPanel() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.init(filenameExtension: "ch8")!] // Only allow .ch8 files
        openPanel.allowsMultipleSelection = false
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                selectRom(fileUrl: url)
            }
        }
    }
    

}
