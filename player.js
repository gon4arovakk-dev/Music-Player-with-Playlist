// player.js
const fs = require('fs');
const readline = require('readline');
const { exec } = require('child_process');
const os = require('os');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

class Playlist {
    constructor() {
        this.songs = [];
    }

    add(name, path) {
        if (!fs.existsSync(path)) {
            console.log(`File not found: ${path}`);
            return false;
        }
        this.songs.push({ name, path });
        console.log(`Added: ${name}`);
        return true;
    }

    remove(index) {
        if (index < 0 || index >= this.songs.length) {
            console.log('Invalid index.');
            return false;
        }
        const removed = this.songs.splice(index, 1)[0];
        console.log(`Removed: ${removed.name}`);
        return true;
    }

    list() {
        if (this.songs.length === 0) {
            console.log('Playlist is empty.');
            return;
        }
        this.songs.forEach((song, i) => {
            console.log(`[${i+1}] ${song.name} (${song.path})`);
        });
    }

    play(index) {
        if (index < 0 || index >= this.songs.length) {
            console.log('Invalid index.');
            return false;
        }
        const song = this.songs[index];
        console.log(`Playing: ${song.name}`);
        this.playFile(song.path);
        return true;
    }

    playFile(path) {
        const platform = os.platform();
        let cmd;
        if (platform === 'win32') {
            cmd = `start "" "${path}"`;
        } else if (platform === 'darwin') {
            cmd = `afplay "${path}"`;
        } else {
            // Linux
            // Try mpg123, ffplay, aplay
            const players = ['mpg123', 'ffplay', 'aplay'];
            // We'll just use the first found; we can't easily check existence in Node without which
            // We'll just try mpg123 as default, and if it fails, user can install.
            cmd = `mpg123 "${path}" || ffplay -nodisp -autoexit "${path}" || aplay "${path}"`;
        }
        exec(cmd, (error) => {
            if (error) {
                console.log(`Error playing: ${error.message}`);
            }
        });
    }

    save(filename) {
        try {
            fs.writeFileSync(filename, JSON.stringify(this.songs, null, 2));
            console.log(`Playlist saved to ${filename}`);
            return true;
        } catch (err) {
            console.log(`Error saving: ${err.message}`);
            return false;
        }
    }

    load(filename) {
        try {
            const data = fs.readFileSync(filename, 'utf8');
            this.songs = JSON.parse(data);
            console.log(`Playlist loaded from ${filename}`);
            return true;
        } catch (err) {
            console.log(`Error loading: ${err.message}`);
            return false;
        }
    }
}

function ask(question) {
    return new Promise((resolve) => {
        rl.question(question, resolve);
    });
}

async function main() {
    const playlist = new Playlist();
    console.log('=== Music Player ===');
    console.log('Commands: add <name> <path>, remove <index>, list, play <index>, save <file>, load <file>, exit');
    while (true) {
        const input = await ask('> ');
        const parts = input.trim().split(/\s+/);
        if (parts.length === 0) continue;
        const cmd = parts[0].toLowerCase();
        switch (cmd) {
            case 'exit':
                console.log('Goodbye!');
                rl.close();
                return;
            case 'add':
                if (parts.length < 3) {
                    console.log('Usage: add <name> <path>');
                    break;
                }
                const name = parts[1];
                const path = parts.slice(2).join(' ');
                playlist.add(name, path);
                break;
            case 'remove':
                if (parts.length !== 2) {
                    console.log('Usage: remove <index>');
                    break;
                }
                const idx = parseInt(parts[1]) - 1;
                if (isNaN(idx)) {
                    console.log('Invalid index.');
                    break;
                }
                playlist.remove(idx);
                break;
            case 'list':
                playlist.list();
                break;
            case 'play':
                if (parts.length !== 2) {
                    console.log('Usage: play <index>');
                    break;
                }
                const playIdx = parseInt(parts[1]) - 1;
                if (isNaN(playIdx)) {
                    console.log('Invalid index.');
                    break;
                }
                playlist.play(playIdx);
                break;
            case 'save':
                if (parts.length !== 2) {
                    console.log('Usage: save <file>');
                    break;
                }
                playlist.save(parts[1]);
                break;
            case 'load':
                if (parts.length !== 2) {
                    console.log('Usage: load <file>');
                    break;
                }
                playlist.load(parts[1]);
                break;
            default:
                console.log('Unknown command. Available: add, remove, list, play, save, load, exit');
        }
    }
}

main().catch(console.error);
