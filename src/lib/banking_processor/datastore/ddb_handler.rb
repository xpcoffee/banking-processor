require 'aws-sdk'
require_relative 'ddb_inserter/balance_inserter'

module BankingProcessor
  module Datastore

    class DynamoDBHandler
      FALLBACK_ACCOUNT = 'FNB 62206800767'

      def initialize(config)
        @config = config

        @client = Aws::DynamoDB::Client.new(
          region: config.aws_region,
          access_key_id: config.aws_access_key,
          secret_access_key: config.aws_secret_key,
          ssl_ca_bundle: config.aws_ca_bundle # Ruby SDK can't find path on Windows - need to set it explicitly
        )

        @balance_inserter = BankingProcessor::Datastore::DynamoDBInserter::BalanceInserter.new(client)
        @transaction_inserter = BankingProcessor::Datastore::DynamoDBInserter::TransactionInserter.new(client)
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

      def transaction_inserter
        @transaction_inserter
      end

      # application specific methods
      def insert_transaction(account, year_month, day, amount, balance, description)
        transaction_inserter.put_transaction(account, year_month, day, amount, balance, description)
        balance_inserter.update_balance(table, year_month, day)
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