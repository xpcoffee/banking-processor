module BankingProcessor
  module Datastore
    module DynamoDB
      class BalanceInserter
        def initialize(client)
          @client = client
        end

        def client
          @client
        end

        def update_balance(table, year_month, day, balance) {
          year = year_month.split('-')[0]
          month_day = "#{year_month.split('-')[1]}-#{day}"

          current_balance = get_balance(year_month, day, date)

          if !current_balance.nil?
            and balance.to_i < current_balance.to_i
            put_balance(table, date, balance) if current_balance.nil?
          end
        }

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

          return nil if resp.nil?
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