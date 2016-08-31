module BankingProcessor
  module Datastore
    module DynamoDB

      # Handles logic specific to inserting entries into the transaction table in DDB
      class TransactionHandler
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

        def get_table(account)
          table = config.transaction_table(account)

          if table.nil?
            fallback_account = config.default_account
            STDERR.puts "[WARN] Unable to find table for account '#{account}'. Using fallback account '#{fallback_account}'."
            table = config.transaction_table(fallback_account)
          end

          table
        end

        def scan(account)
          table = get_table(account)

          scan_options = {
            table_name: table
          }

          resp = ''

          begin
            resp = client.scan(scan_options)
          rescue => e
            STDERR.puts "[ERROR] Unable to scan table #{table}. #{e.class}: #{e.message}"
            Kernel.exit(1)
          end

          transactions = resp.items
        end

        def put_transaction(account, date, amount, balance, description)
          table = get_table(account)

          params = {
            table_name: table,
            item: {
              'year-month' => zero_padded_year_month(date),
              'day' => zero_padded_day(date),
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

        def delete_transaction(account, date, balance)
          table = get_table(account)
          year_month = zero_padded_year_month(date)

          delete_options = {
            table_name: table,
            key: {
              "year-month" => year_month,
              "balance" => balance.to_f
            }
          }

          resp = ''
          begin
            resp = client.delete_item(delete_options);
            print '.'
          rescue => e
            STDERR.puts "[ERROR] Unable to delete transaction #{year_month}/#{balance}. #{e.class}: #{e.message}"
            Kernel.exit(1)
          end
        end

        private

        def zero_padded_day(date)
          date.day.to_s.rjust(2, '0')
        end

        def zero_padded_month(date)
          date.month.to_s.rjust(2, '0')
        end

        def zero_padded_year_month(date)
          "#{date.year}-#{zero_padded_month(date)}"
        end
      end
    end
  end
end
