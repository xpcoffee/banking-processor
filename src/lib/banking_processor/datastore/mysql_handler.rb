require 'rubygems'
require 'mysql2'

module BankingProcessor
  module Datastore
    class MySQLHandler
      def initialize(config)
        @config ||= config
      end

      def config
        @config
      end

      def description
        return "MySQL"
      end

      def client
        @client ||= Mysql2::Client.new(
          :host => config.host,
          :username => config.user,
          :password => config.pass
          )
      end

      def get_databases
        databases = []
        response = client.query("SHOW DATABASES;")
        response.each do |entry|
          databases.push(entry['Database'])
        end
        return databases
      end

      def set_database
        @database_set ||= begin
          puts @database_set

          begin
            response = client.query("USE #{config.database};")
          rescue Mysql2::Error => e
            STDERR.puts "[ERROR] Unable to select database: #{e.message} "
            Kernel.exit(1)
          end

          true
        end
      end

      def insert_transaction(account, date, amount, balance, description)
        set_database()
        client.query("INSERT IGNORE INTO #{config.table} VALUES (\"#{date}\",\"#{account}\",#{amount},#{balance},\"#{description}\");")
      end

      def query(sql_query)
        set_database()
        response = client.query("#{sql_query}")
      end
    end
  end
end