require 'aws-sdk'
require_relative 'dynamodb/balance_inserter'
require_relative 'dynamodb/transaction_handler'

module BankingProcessor
  module Datastore

    class DynamoDBHandler

      def initialize(config)
        @config = config

        @client = Aws::DynamoDB::Client.new(
          region: config.aws_region,
          access_key_id: config.aws_access_key,
          secret_access_key: config.aws_secret_key,
          ssl_ca_bundle: config.aws_ca_bundle # Ruby SDK can't find path on Windows - need to set it explicitly
        )

        @balance_inserter = BankingProcessor::Datastore::DynamoDB::BalanceInserter.new(client, config)
        @transactions = BankingProcessor::Datastore::DynamoDB::TransactionHandler.new(client, config)
      end

      def config
        @config
      end

      def description
        return "DynamoDB"
      end

      def client
        @client
      end

      def balance_inserter
        @balance_inserter
      end

      def transactions
        @transactions
      end

      # application specific methods
      def insert_transaction(account, date, amount, balance, description)
        transactions.put_transaction(account, date, amount, balance, description)
        balance_inserter.update_balance(account, date, balance)
      end

      # generic methods
      def get_tables
        resp = client.list_tables()
        return resp.table_names
      end

      def query(table_name, key_conditions)
        begin
          client.put_item({
            table_name: table,
            key_conditions: key_conditions
            })
        rescue Aws::DynamoDB::Errors::ServiceError => e
          STDERR.puts '[ERROR] Unable to query DynamoDB: ' + e.message
          Kernel.exit(1)
        end
      end

    end
  end
end
