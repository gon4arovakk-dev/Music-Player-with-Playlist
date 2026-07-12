
---

# 💻 Code Implementations

## 1. Python (`player.py`)

```python
# player.py
import os
import json
import subprocess
import sys
import platform

class Playlist:
    def __init__(self):
        self.songs = []  # list of dicts: {"name": str, "path": str}

    def add(self, name, path):
        if not os.path.exists(path):
            print(f"File not found: {path}")
            return False
        self.songs.append({"name": name, "path": path})
        print(f"Added: {name}")
        return True

    def remove(self, index):
        if 0 <= index < len(self.songs):
            removed = self.songs.pop(index)
            print(f"Removed: {removed['name']}")
            return True
        print("Invalid index.")
        return False

    def list(self):
        if not self.songs:
            print("Playlist is empty.")
            return
        for i, song in enumerate(self.songs, 1):
            print(f"[{i}] {song['name']} ({song['path']})")

    def play(self, index):
        if 0 <= index < len(self.songs):
            song = self.songs[index]
            print(f"Playing: {song['name']}")
            self._play_file(song['path'])
            return True
        print("Invalid index.")
        return False

    def _play_file(self, path):
        system = platform.system()
        try:
            if system == "Windows":
                os.startfile(path)
            elif system == "Darwin":
                subprocess.run(["afplay", path], check=True)
            else:  # Linux
                # Try common players
                players = ["mpg123", "ffplay", "aplay"]
                for player in players:
                    try:
                        subprocess.run([player, path], check=True)
                        return
                    except FileNotFoundError:
                        continue
                print("No suitable audio player found. Please install mpg123 or ffplay.")
        except Exception as e:
            print(f"Error playing: {e}")

    def save(self, filename):
        try:
            with open(filename, "w") as f:
                json.dump(self.songs, f, indent=2)
            print(f"Playlist saved to {filename}")
            return True
        except Exception as e:
            print(f"Error saving: {e}")
            return False

    def load(self, filename):
        try:
            with open(filename, "r") as f:
                self.songs = json.load(f)
            print(f"Playlist loaded from {filename}")
            return True
        except Exception as e:
            print(f"Error loading: {e}")
            return False

def main():
    playlist = Playlist()
    print("=== Music Player ===")
    print("Commands: add <name> <path>, remove <index>, list, play <index>, save <file>, load <file>, exit")
    while True:
        try:
            cmd = input("> ").strip().split()
            if not cmd:
                continue
            command = cmd[0].lower()
            if command == "exit":
                print("Goodbye!")
                break
            elif command == "add" and len(cmd) >= 3:
                name = cmd[1]
                path = " ".join(cmd[2:])
                playlist.add(name, path)
            elif command == "remove" and len(cmd) == 2:
                try:
                    idx = int(cmd[1]) - 1
                    playlist.remove(idx)
                except ValueError:
                    print("Invalid index.")
            elif command == "list":
                playlist.list()
            elif command == "play" and len(cmd) == 2:
                try:
                    idx = int(cmd[1]) - 1
                    playlist.play(idx)
                except ValueError:
                    print("Invalid index.")
            elif command == "save" and len(cmd) == 2:
                playlist.save(cmd[1])
            elif command == "load" and len(cmd) == 2:
                playlist.load(cmd[1])
            else:
                print("Unknown command. Available: add, remove, list, play, save, load, exit")
        except KeyboardInterrupt:
            print("\nExiting...")
            break
        except EOFError:
            break

if __name__ == "__main__":
    main()
