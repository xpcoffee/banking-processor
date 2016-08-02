module BankingProcessor
  module Datastore
    module DynamoDB

      # Handles logic specific to inserting entries into the transaction table in DDB
      class TransactionInserter
        def initialize(client, config)
          @client = client
          @config = config
        end

        def client
          @client
        end

        def config
          @config
        end

        def put_transaction(account, date, amount, balance, description)
          table = config.transaction_table(account)
          if table.nil?
            fallback_account = config.default_account
            STDERR.puts "[WARN] Unable to find table for account '#{account}'. Using fallback account '#{fallback_account}'."
            table = config.transaction_table(fallback_account)
          end

          zero_padded_day = date.day.to_s.rjust(2, '0')
          zero_padded_month = date.month.to_s.rjust(2, '0')
          zero_padded_year_month = "#{date.year}-#{zero_padded_month}"


          params = {
            table_name: table,
            item: {
              'year-month' => zero_padded_year_month,
              'day' => zero_padded_day,
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
