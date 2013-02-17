#!/usr/bin/env ruby

END {
  Arc.new(File.expand_path('..', __FILE__)).run(ARGV)
}

require 'pathname'
require 'shellwords'

class Arc
  include Shellwords

  def initialize(path)
    @path = Pathname.new(path)
  end

  def files
    @files ||= @path.children.select { |p| p.directory? }
  end

  def main_for(path)
    path.exist? && path.children.detect { |c| c.basename.to_s.start_with?("main") }
  end

  def editor
    ENV['EDITOR'] || 'vi'
  end

  def title_for(path)
    return unless path
    File.open(path, 'r') { |f| f.gets.strip }
  end

  def run(argv)
    case command = argv.shift
    when '-l'
      list
    when '-s'
      search(argv.shift.to_s)
    when '-h', '--help', nil
      help
    when '-c'
      complete(argv.shift.to_s)
    when '-p', '--path'
      if other = argv.shift
        puts (@path + other).to_s
      else
        puts @path.to_s
      end
    else
      find(command)
    end
  end

  def list
    files.each do |file|
      main = main_for(file)
      left = file.basename.to_s.ljust(30)
      puts "#{left} #{title_for(main)}"
    end
  end

  def find(name)
    name = name.sub(/\.\w+$/, '')
    suffix = $&
    child = @path + name
    main = main_for(child)

    unless main
      child.mkpath
      main = child + "main#{suffix}"
    end

    command = "#{editor} #{shellescape(main.to_s)}"
    exec('sh', '-c', command)
  end

  def search(query)
    IO.popen(['mdfind', '-onlyin', @path.to_s, '-interpret', query]) do |r|
      r.each_line do |line|
        puts Pathname.new(line.strip).relative_path_from(@path)
      end
    end
  end

  def help
    puts <<-EOF
usage: arc file-name.rb
       arc -l
       arc -s query
EOF
  end

  def complete(word)
    puts files.map { |x| x.basename.to_s }.select { |x| x.start_with?(word) }
  end
end

