require_relative '../config'
require_relative '../io/file_handler'
require_relative '../datastore/mysql_handler'
require_relative '../datastore/s3_handler'

# Queries the datastore and processes the results.
# Output is in the form of .csv files, which get uploaded to AWS S3.
# The processor can be run in dryrun mode which stops the files from being uploaded.
module BankingProcessor
  module Processor
    class OutputProcessor
      def initialize(dry = nil)
        @dryrun = dry unless dry.nil?
      end

      def config
        @config ||= BankingProcessor::Config.new
      end

      def dryrun
        @dryrun ||= config.dryrun
      end

      def encryption_handler
        @encryption_handler = config.encryption_handler
      end

      def file_handler
        @file ||= BankingProcessor::IO::FileHandler.new
      end

      def db
        @db ||= BankingProcessor::Datastore::MySQLHandler.new(config)
      end

      def s3
        @s3 ||= BankingProcessor::Datastore::S3Handler.new(
          config.aws_region,
          config.aws_access_key,
          config.aws_secret_key,
          config.aws_ca_bundle
          )
      end

      def csv_data
        @csv_data ||= []
      end

      def export_balance_data
        puts "======================"
        puts "Exporting balance data"
        puts "======================"

        file_path = "#{config.output_path}/#{config.balance_file}"
        export_data_to_csv("#{config.sql_root}/balance/", file_path)
        upload_file_to_s3(file_path) unless dryrun
      end

      def export_breakdown_data
        puts "================================"
        puts "Exporting monthly-breakdown data"
        puts "================================"

        file_path = "#{config.output_path}/#{config.breakdown_file}"
        export_data_to_csv("#{config.sql_root}/monthly-breakdown/", file_path)
        upload_file_to_s3(file_path) unless dryrun
      end

      private

      def export_data_to_csv(sql_path, output_file)
        data = get_data(sql_path)
        begin
          output = File.open(output_file, "w")
          data.each do |query_data|
            output << "#{query_data.join(',')}\n"
          end

          puts "Data exported to #{File.basename(output_file)}"
        ensure
          output.close
        end
      end

      def upload_file_to_s3(filepath)
        s3.upload_file( filepath,
          config.s3_bucket,
          File.basename(filepath) )
        puts "File #{File.basename(filepath)} uploaded to #{config.s3_bucket}"
      end

      def get_data(sql_path)
        @data= {}
        execute_sql_queries(sql_path) { |query_result|
          # Add headings, initialize arrays
          headings = query_result.fields
          headings.each do |heading|
            @data[heading] = []
          end

          # Add values
          query_result.each do |row|
            row.each do |k,v|
              @data[k].push(v.nil? ? 0 : v)
            end
          end
        }

        return @data
      end

      # Execute all the sql queries in the SQL path
      # If the files are encrypted, decrypt them first
      def execute_sql_queries(sql_path)
        db.use_database(config.database)
        puts "Selected database #{config.database}"

        file_handler.for_files("#{sql_path}*.sql") do |filename|
          puts 'Found unencrypted SQL query: ' + File.basename(filename)
          sql_query = File.read(filename)
          result = db.query(sql_query)
          yield(result)
        end

        file_handler.for_files("#{sql_path}*.enc") do |filename|
          puts 'Found encrypted SQL query: ' + File.basename(filename)
          contents = File.read(filename)
          sql_query = encryption_handler.decrypt(contents)
          result = db.query(sql_query)
          yield(result)
        end
        puts "Queries complete."
      end
    end
  end
end
