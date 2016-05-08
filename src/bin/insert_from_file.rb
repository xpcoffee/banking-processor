require 'optparse'
require_relative '../lib/processor'

options = {}
options[:toothless] = false
OptionParser.new do |opts|
    opts.banner = 'Usage: start.rb [options]'
    opts.on('-f FILE', '--file FILE', 'file to be processed') do |file|
        options[:file] = file
    end

    opts.on('-t', '--toothless', 'operation is toothless') do
        options[:toothless] = true
    end

    opts.on_tail('-h', '--help', 'display options') do
        puts opts
        exit
    end
end.parse!

file = options[:file]
if (file.nil? || file.empty?)
    puts "[Bad Input] No file supplied. Please supply a file with '--file'"
    exit
end

processor = InputProcessor.new(options[:toothless])
processor.process(file)