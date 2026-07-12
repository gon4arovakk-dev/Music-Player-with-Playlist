# player.rb
require 'json'

class Playlist
  def initialize
    @songs = []  # each song: {name: ..., path: ...}
  end

  def add(name, path)
    unless File.exist?(path)
      puts "File not found: #{path}"
      return false
    end
    @songs << {name: name, path: path}
    puts "Added: #{name}"
    true
  end

  def remove(index)
    if index < 0 || index >= @songs.size
      puts "Invalid index."
      return false
    end
    removed = @songs.delete_at(index)
    puts "Removed: #{removed[:name]}"
    true
  end

  def list
    if @songs.empty?
      puts "Playlist is empty."
      return
    end
    @songs.each_with_index do |song, i|
      puts "[#{i+1}] #{song[:name]} (#{song[:path]})"
    end
  end

  def play(index)
    if index < 0 || index >= @songs.size
      puts "Invalid index."
      return false
    end
    song = @songs[index]
    puts "Playing: #{song[:name]}"
    play_file(song[:path])
    true
  end

  def play_file(path)
    os = RUBY_PLATFORM
    cmd = nil
    if os =~ /mswin|mingw|windows/
      cmd = "start #{path}"
    elsif os =~ /darwin/
      cmd = "afplay '#{path}'"
    else
      # Linux
      # Try to find a player
      players = ['mpg123', 'ffplay', 'aplay']
      found = players.find { |p| system("which #{p} > /dev/null 2>&1") }
      if found
        cmd = "#{found} '#{path}'"
      else
        puts "No suitable audio player found. Install mpg123 or ffplay."
        return
      end
    end
    system(cmd) rescue puts "Error playing: #{$!.message}"
  end

  def save(filename)
    File.write(filename, JSON.pretty_generate(@songs))
    puts "Playlist saved to #{filename}"
    true
  rescue => e
    puts "Error saving: #{e.message}"
    false
  end

  def load(filename)
    data = File.read(filename)
    @songs = JSON.parse(data, symbolize_names: true)
    puts "Playlist loaded from #{filename}"
    true
  rescue => e
    puts "Error loading: #{e.message}"
    false
  end
end

def main
  playlist = Playlist.new
  puts "=== Music Player ==="
  puts "Commands: add <name> <path>, remove <index>, list, play <index>, save <file>, load <file>, exit"
  loop do
    print "> "
    input = gets.chomp.strip
    next if input.empty?
    parts = input.split
    cmd = parts[0].downcase
    case cmd
    when "exit"
      puts "Goodbye!"
      break
    when "add"
      if parts.size < 3
        puts "Usage: add <name> <path>"
        next
      end
      name = parts[1]
      path = parts[2..-1].join(' ')
      playlist.add(name, path)
    when "remove"
      if parts.size != 2
        puts "Usage: remove <index>"
        next
      end
      idx = parts[1].to_i - 1
      playlist.remove(idx)
    when "list"
      playlist.list
    when "play"
      if parts.size != 2
        puts "Usage: play <index>"
        next
      end
      idx = parts[1].to_i - 1
      playlist.play(idx)
    when "save"
      if parts.size != 2
        puts "Usage: save <file>"
        next
      end
      playlist.save(parts[1])
    when "load"
      if parts.size != 2
        puts "Usage: load <file>"
        next
      end
      playlist.load(parts[1])
    else
      puts "Unknown command. Available: add, remove, list, play, save, load, exit"
    end
  end
end

main if __FILE__ == $0
