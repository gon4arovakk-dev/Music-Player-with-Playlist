// Player.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Diagnostics;

class Song
{
    public string Name { get; set; }
    public string Path { get; set; }
}

class Playlist
{
    private List<Song> songs = new List<Song>();

    public bool Add(string name, string path)
    {
        if (!File.Exists(path))
        {
            Console.WriteLine($"File not found: {path}");
            return false;
        }
        songs.Add(new Song { Name = name, Path = path });
        Console.WriteLine($"Added: {name}");
        return true;
    }

    public bool Remove(int index)
    {
        if (index < 0 || index >= songs.Count)
        {
            Console.WriteLine("Invalid index.");
            return false;
        }
        var removed = songs[index];
        songs.RemoveAt(index);
        Console.WriteLine($"Removed: {removed.Name}");
        return true;
    }

    public void List()
    {
        if (songs.Count == 0)
        {
            Console.WriteLine("Playlist is empty.");
            return;
        }
        for (int i = 0; i < songs.Count; i++)
        {
            Console.WriteLine($"[{i+1}] {songs[i].Name} ({songs[i].Path})");
        }
    }

    public bool Play(int index)
    {
        if (index < 0 || index >= songs.Count)
        {
            Console.WriteLine("Invalid index.");
            return false;
        }
        var song = songs[index];
        Console.WriteLine($"Playing: {song.Name}");
        PlayFile(song.Path);
        return true;
    }

    private void PlayFile(string path)
    {
        try
        {
            if (OperatingSystem.IsWindows())
            {
                Process.Start(new ProcessStartInfo { FileName = "cmd", Arguments = $"/c start {path}", UseShellExecute = false });
            }
            else if (OperatingSystem.IsMacOS())
            {
                Process.Start("afplay", path);
            }
            else // Linux
            {
                // Try mpg123, ffplay, aplay
                var players = new[] { "mpg123", "ffplay", "aplay" };
                bool started = false;
                foreach (var player in players)
                {
                    try
                    {
                        Process.Start(player, path);
                        started = true;
                        break;
                    }
                    catch { }
                }
                if (!started)
                    Console.WriteLine("No suitable audio player found. Install mpg123 or ffplay.");
            }
        }
        catch (Exception e)
        {
            Console.WriteLine($"Error playing: {e.Message}");
        }
    }

    public bool Save(string filename)
    {
        try
        {
            string json = JsonSerializer.Serialize(songs, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(filename, json);
            Console.WriteLine($"Playlist saved to {filename}");
            return true;
        }
        catch (Exception e)
        {
            Console.WriteLine($"Error saving: {e.Message}");
            return false;
        }
    }

    public bool Load(string filename)
    {
        try
        {
            string json = File.ReadAllText(filename);
            songs = JsonSerializer.Deserialize<List<Song>>(json);
            Console.WriteLine($"Playlist loaded from {filename}");
            return true;
        }
        catch (Exception e)
        {
            Console.WriteLine($"Error loading: {e.Message}");
            return false;
        }
    }

    static void Main()
    {
        var playlist = new Playlist();
        Console.WriteLine("=== Music Player ===");
        Console.WriteLine("Commands: add <name> <path>, remove <index>, list, play <index>, save <file>, load <file>, exit");
        while (true)
        {
            Console.Write("> ");
            string input = Console.ReadLine()?.Trim();
            if (string.IsNullOrEmpty(input)) continue;
            string[] parts = input.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            string cmd = parts[0].ToLower();
            switch (cmd)
            {
                case "exit":
                    Console.WriteLine("Goodbye!");
                    return;
                case "add":
                    if (parts.Length < 3)
                    {
                        Console.WriteLine("Usage: add <name> <path>");
                        break;
                    }
                    string name = parts[1];
                    string path = string.Join(" ", parts, 2, parts.Length - 2);
                    playlist.Add(name, path);
                    break;
                case "remove":
                    if (parts.Length != 2)
                    {
                        Console.WriteLine("Usage: remove <index>");
                        break;
                    }
                    if (!int.TryParse(parts[1], out int idx))
                    {
                        Console.WriteLine("Invalid index.");
                        break;
                    }
                    playlist.Remove(idx - 1);
                    break;
                case "list":
                    playlist.List();
                    break;
                case "play":
                    if (parts.Length != 2)
                    {
                        Console.WriteLine("Usage: play <index>");
                        break;
                    }
                    if (!int.TryParse(parts[1], out int playIdx))
                    {
                        Console.WriteLine("Invalid index.");
                        break;
                    }
                    playlist.Play(playIdx - 1);
                    break;
                case "save":
                    if (parts.Length != 2)
                    {
                        Console.WriteLine("Usage: save <file>");
                        break;
                    }
                    playlist.Save(parts[1]);
                    break;
                case "load":
                    if (parts.Length != 2)
                    {
                        Console.WriteLine("Usage: load <file>");
                        break;
                    }
                    playlist.Load(parts[1]);
                    break;
                default:
                    Console.WriteLine("Unknown command. Available: add, remove, list, play, save, load, exit");
                    break;
            }
        }
    }
}
