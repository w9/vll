require 'optparse'
require 'pp'

options = {
  :separator => /[,\t]/,
  :padding => 1,
  :skip => 0,
  :comment => /^#/,
  :probe_lines => 100
}

OptionParser.new do |opts|
  opts.banner = 'Usage: example.rb [options]'
  opts.separator ''
  opts.separator 'Options:'
  opts.separator '-' * 80

  opts.on('-s', '--separator [REGEX]',
          'regex to match the separator',
          '  default: [,\t]') do |s|
    begin
      options[:separator] = Regexp.new(s)
    rescue
      puts 'Warning: Problems encountered when processing the regex.'
      puts "Warning: Default value \"#{options[:separator].source}\" is used."
    end
  end

  opts.on('-p', '--padding [NUM_OF_SPACES]',
          'number of spaces that separate the columns',
          '  default: 1') do |p|
    options[:padding] = p.to_i
  end

  opts.on('-k', '--skip [NUM_OF_LINES]',
          'number of top lines to skip',
          '  default: 0') do |k|
    options[:skip] = k.to_i
  end

  opts.on('-p', '--probe-lines [NUM_OF_LINES]',
          'number of top lines used for fast estimation',
          '  default: 100') do |p|
    options[:probe_lines] = p.to_i
  end
          
  opts.on('-c', '--comment [REGEX]',
          'regex to match lines to ignore',
          '  default: ^#') do |c|
    begin
      options[:comment] = Regexp.new(c)
    rescue
      puts 'Warning: Problems encountered when processing the regex.'
      puts "Warning: Default value \"#{options[:comment].source}\" is used."
    end
  end
end.parse!

if ARGV.empty?
  abort 'Error: No filename found.'
else
  file_name = ARGV[0]
end

if !File.exists? file_name
  abort "Error: file \"#{file_name}\" not found."
end

# TODO: add an option for choosing left or right justify

max_widths = []

f_iter = File.foreach(file_name)

lnum = 0
options[:probe_lines].times do
  begin
    line = f_iter.next rescue break
    lnum += 1
  end while lnum < options[:skip] or line =~ options[:comment]
  line.chomp.split(options[:separator]).each_with_index do |c, i|
    # -1 because it's possible that c is empty and i is out of range
    if max_widths.fetch(i, -1) < c.length then max_widths[i] = c.length end
  end
end
  
f_iter.rewind

f_iter.with_index do |line, lnum|
  if lnum < options[:skip] or line =~ options[:comment] then
    print line
    next
  end
  line.chomp.split(options[:separator]).each_with_index do |c, i|
    if max_widths.fetch(i, -1) < c.length then max_widths[i] = c.length end
    print c.ljust(max_widths[i] + options[:padding]) rescue break
  end
  print "\n" rescue break
end
