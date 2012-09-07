#!//usr/bin/env ruby

directory = ARGV.shift 
@remove_text = ARGV.shift || ".html"

def iterate_directory(directory)
  Dir.foreach(directory) do |entry|
    next unless valid_dir?(entry)
    if File.directory?(entry)
      iterate_directory(entry)
    else
      next unless valid_file?(entry)
      clean_links(File.realpath("#{directory}/#{entry}"))
    end
  end
end

def clean_links(entry)
  file = File.open(entry, "r")
  # Find the link target
  # <a\s*href=\s*"([a-z0-9_]+.html)"\s*>
  
  # Find only the ending that should be removed
  # <a\s*href=\s*"[a-z0-9_]+(.html)"\s*>
  #file.read.match(/<a\s*href=\s*"[a-z0-9_]+(#{@remove_text})"\s*>/mi) do |match|
  #  puts match.captures
  #end
  
  data = file.read
  file.close
  
  # One line version
  #data.gsub!(/(<a\s*href=\s*"[a-z0-9_]+)#{@remove_text}("\s*>)/mi, '\1\2')
  
  # Block version with verbosity
  data.gsub!(/(<a\s*href=\s*"[a-z0-9_]+)#{@remove_text}("\s*>)/mi) do |match|
    puts "Substiute in File: #{file.path} \tReplace: #{match} \twith: #{$1}#{$2}"
    "#{$1}#{$2}"
  end
  
  # Write the file
  File.open(entry, "w") {|file| file << data}
end

def valid_file?(entry)
  true if File.fnmatch("*.html", entry)
end

def valid_dir?(entry)
  true unless entry == "." || entry == ".."
end

iterate_directory(directory)