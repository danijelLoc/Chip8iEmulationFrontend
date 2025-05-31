//
//  iOSMenuSheetView.swift
//  Chip8iEmulator
//
//  Created by Danijel Stracenski on 24.02.2025..
//

import Chip8iEmulationCore
import SwiftUI
import UniformTypeIdentifiers

struct iOSMenuSheetView: View {
    @Binding var isPresented: Bool

    @Binding var selectedProgram: Chip8Program?
    @Binding var recentFiles: Set<URL>
    @Binding var bundledRoms: [String]

    @State private var showFileImporter: Bool = false

    var body: some View {
        NavigationView {
            List {
                // Load from files option
                Section {
                    Button(action: { showFileImporter.toggle() }) {
                        Label("Load game from Files...", systemImage: "folder.fill")
                    }
                }

                // Recent Files Section
                if !recentFiles.isEmpty {
                    Section(header: Text("Recent Game Files")) {
                        ForEach(Array(recentFiles), id: \.self) { file in
                            Button(action: { selectRom(fileUrl: file) }) {
                                Label(
                                    file.lastPathComponent,
                                    systemImage: "clock.arrow.circlepath")
                            }
                        }
                    }
                }

                // Built-in Games
                Section(header: Text("Built-in Games")) {
                    ForEach(bundledRoms, id: \.self) { rom in
                        Button(action: { selectRom(bundle: rom) }) {
                            Label(rom, systemImage: "gamecontroller.fill")
                        }
                    }
                }
            }
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                loadRecentFileList()
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [UTType.data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectRom(fileUrl: url)
                    }
                case .failure(let error):
                    print("File import failed: \(error.localizedDescription)")
                }
            }

        }
    }

    func selectRom(bundle: String) {
        guard let fileUrl = Utils.bundledRomUrl(name: bundle) else { return }
        let program = Utils.safeLoadProgramRom(from: fileUrl)
        selectedProgram = program
        isPresented = false
    }

    func selectRom(fileUrl: URL) {
        let program = Utils.safeLoadProgramRom(from: fileUrl)
        recentFiles.insert(fileUrl)
        selectedProgram = program
        isPresented = false
    }

    func loadRecentFileList() {
        if let savedFiles = UserDefaults.standard.array(forKey: "recentFiles")
            as? [URL]
        {
            recentFiles = Set(savedFiles)
        }
    }
}
