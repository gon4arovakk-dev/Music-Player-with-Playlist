🎵 Music Player with Playlist

A lightweight **command‑line music player** that manages a playlist and plays songs using your system’s default media player.  
Add songs, remove them, list your playlist, and even save/load playlists to/from a file.  
Built in **7 programming languages** – perfect for learning, music lovers, or quick prototyping.

## ✨ Features
- **Add songs** – add a song with a name and file path.
- **Remove songs** – remove a song by its index.
- **List playlist** – display all songs with index numbers.
- **Play song** – play a selected song using the system’s default player (or a command‑line player).
- **Save playlist** – save the current playlist to a JSON or text file.
- **Load playlist** – load a previously saved playlist from a file.
- **Cross‑platform** – works on Windows, macOS, and Linux.

## 🗂 Languages & Files
| Language          | File            |
|-------------------|-----------------|
| Python            | `player.py`     |
| Go                | `player.go`     |
| JavaScript (Node) | `player.js`     |
| C#                | `Player.cs`     |
| Java              | `Player.java`   |
| Ruby              | `player.rb`     |
| Swift             | `player.swift`  |

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler.

| Language | Command |
|----------|---------|
| Python   | `python player.py` |
| Go       | `go run player.go` |
| JavaScript | `node player.js` |
| C#       | `dotnet run` (or `csc Player.cs && Player.exe`) |
| Java     | `javac Player.java && java Player` |
| Ruby     | `ruby player.rb` |
| Swift    | `swift player.swift` |

**Note:** To play audio, you may need to install a command‑line player:
- **macOS**: `afplay` (built‑in)
- **Linux**: `mpg123`, `ffplay`, or `aplay`
- **Windows**: `start` (works with .mp3, .wav, etc.)

The programs will try to detect your OS and use the appropriate command.

## 📊 Example Session
=== Music Player ===
Commands: add <name> <path>, remove <index>, list, play <index>, save <file>, load <file>, exit

add MySong /home/user/music/song.mp3
Added: MySong

list
[1] MySong (/home/user/music/song.mp3)

play 1
Playing: MySong

save playlist.json
Playlist saved to playlist.json

exit
Goodbye!

text

## 🔧 Commands
| Command | Description |
|---------|-------------|
| `add <name> <path>` | Add a song with a name and file path |
| `remove <index>` | Remove song at given index |
| `list` | Show all songs |
| `play <index>` | Play the song at given index |
| `save <file>` | Save playlist to a JSON file |
| `load <file>` | Load playlist from a JSON file |
| `exit` | Quit the player |

## 📁 Playlist File Format
The playlist is saved as a JSON array of objects:
```json
[{"name":"MySong","path":"/home/user/music/song.mp3"}, ...]
🤝 Contributing
Add support for shuffle, volume control, or a graphical interface – PRs welcome!

📜 License
MIT – use freely.
