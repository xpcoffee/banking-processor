require_relative '../config'
require_relative 'mysql_handler'
require_relative 'ddb_handler'

module BankingProcessor
  module Datastore
    class DatastoreFacade
        def initialize(config)
            @config = config
            select_datastore(config.datastore)
        end

        def select_datastore(type)
            case type
            when 'dynamo'
                @datastore = BankingProcessor::Datastore::DynamoDBHandler.new(config)
            when 'mysql'
                @datastore = BankingProcessor::Datastore::MySQLHandler.new(config)
            else
                STDERR.puts('Unrecognized datastore. Exiting.')
                Kernel.exit(1)
            end
        end

        def config
            @config
        end

        def datastore
            @datastore
        end

        def description
            datastore.description
        end

        def table
            @table = config.dynamo_table
        end

        def insert_transaction(account, year_month, day, amount, balance, description)
            datastore.insert_transaction(account, year_month, day, amount, balance, description)
        end

        def update_balance(date, balance)
        end

        def get_records_for_year_month(table_name, year_month)
            params = {
                table_name: table_name,

            }
        end

         def get_records_after_date(table_name, date)
           value = "#{date.year}-#{date.month}"
           operator = 'GT'

           key_conditions = {
             'year-month' => {
               attribute_value_list: [value]
               comparison_operator: operator
             }
           }

           query(table_name, key_conditions);
         end

        def query(statement)
            datastore.query(statement)
        end
    end
  end
end