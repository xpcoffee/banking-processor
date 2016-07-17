require 'aws-sdk'

module BankingProcessor
  module Datastore
    class DDBHandler
      def initialize(region, access_key, secret_key, ca_bundle)
        @client = Aws::DynamoDB::Client.new(
          region: region,
          access_key_id: access_key,
          secret_access_key: secret_key,
          ssl_ca_bundle: ca_bundle # Ruby SDK can't find path on Windows - need to set it explicitly
        )
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

      def generate_account_table_name(account)
        @table ||= begin
          bank_account = account.split(' ')
          [bank_account[0], bank_account[1], 'banking-data'].join('-')
        end
      end

      def insert_transaction(account, date, amount, balance, description)
        begin
          client.put_item({
            table_name: generate_account_table_name(account),
            item: {
              'date' => date,
              'balance' => balance,
              'amount' => amount,
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