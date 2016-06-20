require 'optparse'
require_relative '../lib/processors/input_processor'

options = {}
OptionParser.new do |opts|
    opts.banner = 'Usage: start.rb [options]'
    opts.on('-f FILE', '--file FILE', 'file to be processed') do |file|
        options[:file] = file
    end

    opts.on('-t', '--dryrun', 'operation is dryrun') do
        options[:dryrun] = true
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

processor = InputProcessor.new(options[:dryrun])
processor.process(file)