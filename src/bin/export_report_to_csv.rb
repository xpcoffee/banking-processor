require 'optparse'
require_relative '../lib/output_processor'

options = {}
options[:toothless] = false
OptionParser.new do |opts|
    opts.banner = 'Usage: start.rb [options]'
    opts.on('-m', '--monthly-breakdown FILE', 'output file for monthly breakdown data') do |file|
        options[:monthly_breakdown_file] = file
    end

    opts.on('-b', '--balance FILE', 'output file for balance data') do |file|
        options[:balance_file] = file
    end

    opts.on_tail('-h', '--help', 'display options') do
        puts opts
        exit
    end
end.parse!

def assert_not_nil(object, message)
    if (object.nil?)
        puts "[Bad Input] #{message}"
        exit
    end
end

assert_not_nil(options[:monthly_breakdown_file], "Please supply a monthly breakdown file name with -m")
assert_not_nil(options[:balance_file], "Please supply balance file name with -b")

processor = OutputProcessor.new
processor.export_balance_data_to_csv(options[:balance_file])
processor.export_breakdown_data_to_csv(options[:monthly_breakdown_file])