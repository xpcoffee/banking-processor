module BankingProcessor
  module Datastore
    module DynamoDB
      class BalanceInserter
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

        def update_balance(account, date, balance)
          table = config.balance_table(account)
          if table.nil?
            fallback_account = config.default_account
            STDERR.puts "[WARN] Unable to find table for account '#{account}'. Using fallback account '#{fallback_account}'."
            table = config.balance_table(fallback_account)
          end

          zero_padded_month = date.month.to_s.rjust(2,'0')
          zero_padded_day = date.day.to_s.rjust(2,'0')
          zero_padded_month_day = "#{zero_padded_month}-#{zero_padded_day}"

          current_balance = get_balance(table, date.year.to_s, zero_padded_month_day)

          if ( current_balance.nil? ) || ( balance.to_i < current_balance.to_i )
            put_balance(table, date.year.to_s, zero_padded_month_day, balance) if current_balance.nil?
          end
        end

        def get_balance(table, year, month_day)
          params = {
            table_name: table,
            key: {
              'year' => year,
              'month-day' => month_day
            }
          }

          resp = nil
          begin
            resp = client.get_item(params)
          rescue Aws::DynamoDB::Errors::ServiceError => e
            STDERR.puts '[ERROR] Unable to get item from DynamoDB: ' + e.message
            Kernel.exit(1)
          end

          return nil if resp.nil? or resp.item.nil?
          resp.item['balance']
        end

        def put_balance(table, year, month_day, balance)
          params = {
            table_name: table,
            item: {
              'year' => year,
              'month-day' => month_day,
              'balance' => balance
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