// player.go
package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
)

type Song struct {
	Name string `json:"name"`
	Path string `json:"path"`
}

type Playlist struct {
	songs []Song
}

func (p *Playlist) add(name, path string) bool {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		fmt.Println("File not found:", path)
		return false
	}
	p.songs = append(p.songs, Song{Name: name, Path: path})
	fmt.Printf("Added: %s\n", name)
	return true
}

func (p *Playlist) remove(index int) bool {
	if index < 0 || index >= len(p.songs) {
		fmt.Println("Invalid index.")
		return false
	}
	removed := p.songs[index]
	p.songs = append(p.songs[:index], p.songs[index+1:]...)
	fmt.Printf("Removed: %s\n", removed.Name)
	return true
}

func (p *Playlist) list() {
	if len(p.songs) == 0 {
		fmt.Println("Playlist is empty.")
		return
	}
	for i, song := range p.songs {
		fmt.Printf("[%d] %s (%s)\n", i+1, song.Name, song.Path)
	}
}

func (p *Playlist) play(index int) bool {
	if index < 0 || index >= len(p.songs) {
		fmt.Println("Invalid index.")
		return false
	}
	song := p.songs[index]
	fmt.Printf("Playing: %s\n", song.Name)
	playFile(song.Path)
	return true
}

func playFile(path string) {
	var cmd *exec.Cmd
	switch runtime.GOOS {
	case "windows":
		cmd = exec.Command("cmd", "/c", "start", path)
	case "darwin":
		cmd = exec.Command("afplay", path)
	default: // linux
		// Try mpg123, ffplay, aplay
		if _, err := exec.LookPath("mpg123"); err == nil {
			cmd = exec.Command("mpg123", path)
		} else if _, err := exec.LookPath("ffplay"); err == nil {
			cmd = exec.Command("ffplay", "-nodisp", "-autoexit", path)
		} else if _, err := exec.LookPath("aplay"); err == nil {
			cmd = exec.Command("aplay", path)
		} else {
			fmt.Println("No suitable audio player found. Install mpg123 or ffplay.")
			return
		}
	}
	if cmd != nil {
		err := cmd.Run()
		if err != nil {
			fmt.Printf("Error playing: %v\n", err)
		}
	}
}

func (p *Playlist) save(filename string) bool {
	data, err := json.MarshalIndent(p.songs, "", "  ")
	if err != nil {
		fmt.Println("Error encoding JSON:", err)
		return false
	}
	err = os.WriteFile(filename, data, 0644)
	if err != nil {
		fmt.Println("Error saving:", err)
		return false
	}
	fmt.Printf("Playlist saved to %s\n", filename)
	return true
}

func (p *Playlist) load(filename string) bool {
	data, err := os.ReadFile(filename)
	if err != nil {
		fmt.Println("Error reading file:", err)
		return false
	}
	var songs []Song
	err = json.Unmarshal(data, &songs)
	if err != nil {
		fmt.Println("Error parsing JSON:", err)
		return false
	}
	p.songs = songs
	fmt.Printf("Playlist loaded from %s\n", filename)
	return true
}

func main() {
	playlist := &Playlist{}
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("=== Music Player ===")
	fmt.Println("Commands: add <name> <path>, remove <index>, list, play <index>, save <file>, load <file>, exit")
	for {
		fmt.Print("> ")
		if !scanner.Scan() {
			break
		}
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}
		parts := strings.Fields(line)
		cmd := strings.ToLower(parts[0])
		switch cmd {
		case "exit":
			fmt.Println("Goodbye!")
			return
		case "add":
			if len(parts) < 3 {
				fmt.Println("Usage: add <name> <path>")
				continue
			}
			name := parts[1]
			path := strings.Join(parts[2:], " ")
			playlist.add(name, path)
		case "remove":
			if len(parts) != 2 {
				fmt.Println("Usage: remove <index>")
				continue
			}
			idx, err := strconv.Atoi(parts[1])
			if err != nil {
				fmt.Println("Invalid index.")
				continue
			}
			playlist.remove(idx - 1)
		case "list":
			playlist.list()
		case "play":
			if len(parts) != 2 {
				fmt.Println("Usage: play <index>")
				continue
			}
			idx, err := strconv.Atoi(parts[1])
			if err != nil {
				fmt.Println("Invalid index.")
				continue
			}
			playlist.play(idx - 1)
		case "save":
			if len(parts) != 2 {
				fmt.Println("Usage: save <file>")
				continue
			}
			playlist.save(parts[1])
		case "load":
			if len(parts) != 2 {
				fmt.Println("Usage: load <file>")
				continue
			}
			playlist.load(parts[1])
		default:
			fmt.Println("Unknown command. Available: add, remove, list, play, save, load, exit")
		}
	}
}
