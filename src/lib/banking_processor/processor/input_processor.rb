require_relative '../io/file_handler'
require_relative '../io/preety_output'
require_relative '../datastore/mysql_handler'
require_relative '../config'

module BankingProcessor
  module Processor
    class InputProcessor
      def initialize(dry = nil)
        @dryrun = dry unless dry.nil?
      end

      def config
        @config ||= BankingProcessor::Config.new
      end

      def dryrun
        @dryrun ||= config.dryrun
      end

      def file
        @file ||= BankingProcessor::IO::FileHandler.new
      end

      def db
        @db ||= BankingProcessor::Datastore::MySQLHandler.new(config)
      end

      def counter
        @counter ||= 0
      end

      def preety
        @preety ||= BankingProcessor::IO::PreetyOutput.new
      end

      def process(path)
        preety.heading("Inserting data from #{File.basename(path)} into #{db.description}")

        file.for_contents(path) { |line| process_line(line) }
        puts ''

        puts "Proccessing complete. Processed #{counter} entries."

        preety.end_section()
      end

      def process_line(line)

        if begins_with_date(line)
          data = line.split(config.data_delimiter)

          account = config.accounts[0]
          date = data[0].strip
          amount = data[1].strip
          balance = data[2].strip
          description = data[3].strip

          if balance == 0
            puts "[WARN] Skipping 0 balance entry: #{amount} #{description}"
            return
          end

          if dryrun
            puts "#{date} #{account} #{amount} #{balance} #{description}"
            return
          else
            #Progress indicator
            #print '.'
          end

          db.insert_transaction(
            account,
            date,
            amount,
            balance,
            description
            )

          @counter = counter + 1
        end
      end

      private

      def begins_with_date(str)
        str =~ /^[0-9]{4}\/[0-9]{2}\/[0-9]{2}/
      end

    end
  end
end
