require 'rubygems'
require 'mysql2'

module BankingProcessor
  module Datastore
    class MySQLHandler
      def initialize(config)
        @config ||= config
      end

      def client
        @client ||= Mysql2::Client.new(
          :host => @config.host,
          :username => @config.user,
          :password => @config.pass
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

      def use_database(database)
        response = client.query("USE #{database};")
        return true if response == "Database changed"
        return response
      end

      def insert_transaction(date, account, amount, balance, description)
        client.query("INSERT IGNORE INTO #{@config.table} VALUES (\"#{date}\",\"#{account}\",#{amount},#{balance},\"#{description}\");")
      end

      def query(sql_query)
        response = client.query("#{sql_query}")
      end
    end
  end
end