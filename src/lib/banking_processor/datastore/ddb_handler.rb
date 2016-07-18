require 'aws-sdk'

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

      def get_tables
        resp = client.list_tables()
        return resp.table_names
      end

      def insert_transaction(account, yearmonth, day, amount, balance, description)
        begin
          client.put_item({
            table_name: config.dynamo_table(account),
            item: {
              'year-month' => year_month,
              'day' => day,
              'balance' => balance.to_f,
              'amount' => amount.to_f,
              'description' => description
            }
            })
        rescue Aws::DynamoDB::Errors::ServiceError => e
          STDERR.puts '[ERROR] Unable to add transaction to DynamoDB: ' + e.message
          Kernel.exit(1)
        end
      end

    end
  end
end