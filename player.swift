// player.swift
import Foundation

struct Song: Codable {
    let name: String
    let path: String
}

class Playlist {
    private var songs: [Song] = []

    func add(name: String, path: String) -> Bool {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            print("File not found: \(path)")
            return false
        }
        songs.append(Song(name: name, path: path))
        print("Added: \(name)")
        return true
    }

    func remove(index: Int) -> Bool {
        guard index >= 0 && index < songs.count else {
            print("Invalid index.")
            return false
        }
        let removed = songs.remove(at: index)
        print("Removed: \(removed.name)")
        return true
    }

    func list() {
        if songs.isEmpty {
            print("Playlist is empty.")
            return
        }
        for (i, song) in songs.enumerated() {
            print("[\(i+1)] \(song.name) (\(song.path))")
        }
    }

    func play(index: Int) -> Bool {
        guard index >= 0 && index < songs.count else {
            print("Invalid index.")
            return false
        }
        let song = songs[index]
        print("Playing: \(song.name)")
        playFile(path: song.path)
        return true
    }

    private func playFile(path: String) {
        #if os(macOS)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
        process.arguments = [path]
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Error playing: \(error)")
        }
        #elseif os(Linux)
        // Try mpg123, ffplay, aplay
        let players = ["mpg123", "ffplay", "aplay"]
        var started = false
        for player in players {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
            process.arguments = [player]
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            do {
                try process.run()
                process.waitUntilExit()
                if process.terminationStatus == 0 {
                    // Player exists
                    let playProcess = Process()
                    playProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                    playProcess.arguments = [player, path]
                    try playProcess.run()
                    playProcess.waitUntilExit()
                    started = true
                    break
                }
            } catch {}
        }
        if !started {
            print("No suitable audio player found. Install mpg123 or ffplay.")
        }
        #elseif os(Windows)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "C:/Windows/System32/cmd.exe")
        process.arguments = ["/c", "start", path]
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Error playing: \(error)")
        }
        #endif
    }

    func save(filename: String) -> Bool {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(songs)
            try data.write(to: URL(fileURLWithPath: filename))
            print("Playlist saved to \(filename)")
            return true
        } catch {
            print("Error saving: \(error)")
            return false
        }
    }

    func load(filename: String) -> Bool {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filename))
            let decoder = JSONDecoder()
            songs = try decoder.decode([Song].self, from: data)
            print("Playlist loaded from \(filename)")
            return true
        } catch {
            print("Error loading: \(error)")
            return false
        }
    }
}

func main() {
    let playlist = Playlist()
    print("=== Music Player ===")
    print("Commands: add <name> <path>, remove <index>, list, play <index>, save <file>, load <file>, exit")
    while true {
        print("> ", terminator: "")
        guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { break }
        if input.isEmpty { continue }
        let parts = input.split(separator: " ", maxSplits: 2).map(String.init)
        let cmd = parts[0].lowercased()
        switch cmd {
        case "exit":
            print("Goodbye!")
            return
        case "add":
            if parts.count < 3 {
                print("Usage: add <name> <path>")
                continue
            }
            let name = parts[1]
            let path = parts[2]
            _ = playlist.add(name: name, path: path)
        case "remove":
            if parts.count != 2 {
                print("Usage: remove <index>")
                continue
            }
            guard let idx = Int(parts[1]) else {
                print("Invalid index.")
                continue
            }
            _ = playlist.remove(index: idx - 1)
        case "list":
            playlist.list()
        case "play":
            if parts.count != 2 {
                print("Usage: play <index>")
                continue
            }
            guard let idx = Int(parts[1]) else {
                print("Invalid index.")
                continue
            }
            _ = playlist.play(index: idx - 1)
        case "save":
            if parts.count != 2 {
                print("Usage: save <file>")
                continue
            }
            _ = playlist.save(filename: parts[1])
        case "load":
            if parts.count != 2 {
                print("Usage: load <file>")
                continue
            }
            _ = playlist.load(filename: parts[1])
        default:
            print("Unknown command. Available: add, remove, list, play, save, load, exit")
        }
    }
}

main()
