// Player.java
import java.io.*;
import java.nio.file.*;
import java.util.*;
import com.google.gson.*;

class Song {
    String name;
    String path;
}

public class Player {
    private List<Song> songs = new ArrayList<>();
    private final Gson gson = new GsonBuilder().setPrettyPrinting().create();

    public boolean add(String name, String path) {
        if (!Files.exists(Paths.get(path))) {
            System.out.println("File not found: " + path);
            return false;
        }
        Song s = new Song();
        s.name = name;
        s.path = path;
        songs.add(s);
        System.out.println("Added: " + name);
        return true;
    }

    public boolean remove(int index) {
        if (index < 0 || index >= songs.size()) {
            System.out.println("Invalid index.");
            return false;
        }
        Song removed = songs.remove(index);
        System.out.println("Removed: " + removed.name);
        return true;
    }

    public void list() {
        if (songs.isEmpty()) {
            System.out.println("Playlist is empty.");
            return;
        }
        for (int i = 0; i < songs.size(); i++) {
            System.out.printf("[%d] %s (%s)%n", i+1, songs.get(i).name, songs.get(i).path);
        }
    }

    public boolean play(int index) {
        if (index < 0 || index >= songs.size()) {
            System.out.println("Invalid index.");
            return false;
        }
        Song song = songs.get(index);
        System.out.println("Playing: " + song.name);
        playFile(song.path);
        return true;
    }

    private void playFile(String path) {
        String os = System.getProperty("os.name").toLowerCase();
        try {
            if (os.contains("win")) {
                Runtime.getRuntime().exec(new String[]{"cmd", "/c", "start", path});
            } else if (os.contains("mac")) {
                Runtime.getRuntime().exec(new String[]{"afplay", path});
            } else {
                // Linux: try mpg123, ffplay, aplay
                String[] players = {"mpg123", "ffplay", "aplay"};
                boolean started = false;
                for (String player : players) {
                    try {
                        Runtime.getRuntime().exec(new String[]{player, path});
                        started = true;
                        break;
                    } catch (IOException e) {}
                }
                if (!started) {
                    System.out.println("No suitable audio player found. Install mpg123 or ffplay.");
                }
            }
        } catch (Exception e) {
            System.out.println("Error playing: " + e.getMessage());
        }
    }

    public boolean save(String filename) {
        try (FileWriter fw = new FileWriter(filename)) {
            String json = gson.toJson(songs);
            fw.write(json);
            System.out.println("Playlist saved to " + filename);
            return true;
        } catch (Exception e) {
            System.out.println("Error saving: " + e.getMessage());
            return false;
        }
    }

    public boolean load(String filename) {
        try (FileReader fr = new FileReader(filename)) {
            Song[] loaded = gson.fromJson(fr, Song[].class);
            songs = new ArrayList<>(Arrays.asList(loaded));
            System.out.println("Playlist loaded from " + filename);
            return true;
        } catch (Exception e) {
            System.out.println("Error loading: " + e.getMessage());
            return false;
        }
    }

    public static void main(String[] args) throws IOException {
        Player player = new Player();
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("=== Music Player ===");
        System.out.println("Commands: add <name> <path>, remove <index>, list, play <index>, save <file>, load <file>, exit");
        while (true) {
            System.out.print("> ");
            String input = reader.readLine();
            if (input == null) break;
            input = input.trim();
            if (input.isEmpty()) continue;
            String[] parts = input.split("\\s+");
            String cmd = parts[0].toLowerCase();
            switch (cmd) {
                case "exit":
                    System.out.println("Goodbye!");
                    return;
                case "add":
                    if (parts.length < 3) {
                        System.out.println("Usage: add <name> <path>");
                        break;
                    }
                    String name = parts[1];
                    String path = String.join(" ", Arrays.copyOfRange(parts, 2, parts.length));
                    player.add(name, path);
                    break;
                case "remove":
                    if (parts.length != 2) {
                        System.out.println("Usage: remove <index>");
                        break;
                    }
                    try {
                        int idx = Integer.parseInt(parts[1]) - 1;
                        player.remove(idx);
                    } catch (NumberFormatException e) {
                        System.out.println("Invalid index.");
                    }
                    break;
                case "list":
                    player.list();
                    break;
                case "play":
                    if (parts.length != 2) {
                        System.out.println("Usage: play <index>");
                        break;
                    }
                    try {
                        int idx = Integer.parseInt(parts[1]) - 1;
                        player.play(idx);
                    } catch (NumberFormatException e) {
                        System.out.println("Invalid index.");
                    }
                    break;
                case "save":
                    if (parts.length != 2) {
                        System.out.println("Usage: save <file>");
                        break;
                    }
                    player.save(parts[1]);
                    break;
                case "load":
                    if (parts.length != 2) {
                        System.out.println("Usage: load <file>");
                        break;
                    }
                    player.load(parts[1]);
                    break;
                default:
                    System.out.println("Unknown command. Available: add, remove, list, play, save, load, exit");
            }
        }
    }
}
