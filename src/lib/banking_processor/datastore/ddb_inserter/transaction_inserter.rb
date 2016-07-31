module BankingProcessor
  module Datastore
    module DynamoDBInserter

      # Handles logic specific to inserting entries into the transaction table in DDB
      class TransactionInserter
        def initialize(client)
          @client = client
        end

        def client
          @client
        end

        def put_transaction(account, year_month, day, amount, balance, description)
          table = config.dynamo_table(account)
          if table.nil?
            STDERR.puts "[WARN] Unable to find table for account '#{account}'. Using fallback account '#{FALLBACK_ACCOUNT}'."
            table = config.dynamo_table(FALLBACK_ACCOUNT)
          end

          params = {
            table_name: table,
            item: {
              'year-month' => year_month,
              'day' => day,
              'balance' => balance.to_f,
              'amount' => amount.to_f,
              'description' => description
            }
          }

          begin
            client.put_item(params)
          rescue Aws::DynamoDB::Errors::ServiceError => e
            STDERR.puts '[ERROR] Unable to add transaction to DynamoDB: ' + e.message
            Kernel.exit(1)
          end
        end
      end
    end
  end
end
