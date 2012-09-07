#!//usr/bin/env ruby
require 'optparse'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options] directory_path"
  opts.on("-v", "--verbose", "Print out what we have done") do
    options[:verbose] = true
  end
  opts.on("-d", "--dry-run", "Just print out the replaced file content without actually writing them to disk") do
    options[:dry-run] = true
  end
  opts.on("-f FILETYPE", "Give the filetypes extension you want to be parsed e.g. '.html'(default) ") do |suffix|
    options[:suffix] = suffix
  end
end

option_parser.parse!

if ARGV.empty?
  puts "error: you must supply a directory_path to the files you want to be parsed"
  puts
  puts option_parser.help
else
  directory = ARGV[0]
end

@remove_text = options[:suffix] || ".html"

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
  data = file.read
  file.close
  
  # One line version
  #data.gsub!(/(<a\s*href=\s*"[a-z0-9_]+)#{@remove_text}("\s*>)/mi, '\1\2')
  
  # Block version with verbosity
  data.gsub!(/(<a\s*href=\s*"[a-z0-9_]+)#{@remove_text}("\s*>)/mi) do |match|
    puts "Substiute in File: #{file.path} \tReplace: #{match} \twith: #{$1}#{$2}" if options[:verbose]
    "#{$1}#{$2}"
  end
  
  # Write the file or just print out what has happend without writing to disk
  if options[:dry-run]
    puts data
  else
    File.open(entry, "w") {|file| file << data}
  end
end

def valid_file?(entry)
  true if File.fnmatch("*.html", entry)
end

def valid_dir?(entry)
  true unless entry == "." || entry == ".."
end

iterate_directory(directory) if directory