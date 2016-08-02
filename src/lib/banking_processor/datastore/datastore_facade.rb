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

        def insert_transaction(account, date, amount, balance, description)
            datastore.insert_transaction(account, date, amount, balance, description)
        end

        def query(statement)
            datastore.query(statement)
        end
    end
  end
end