# Run this in a screen - it can take a while.

require_relative '../lib/banking_processor/datastore/datastore_facade'

config = BankingProcessor::Config.new
datastore = BankingProcessor::Datastore::DatastoreFacade.new(config)

datastore.select_datastore('mysql')
sql_query = "SELECT * FROM #{config.table};"
mysql_data = datastore.query(sql_query)

datastore.select_datastore('dynamo')
puts 'Starting backfill.'
mysql_data.each do |item|
    account = item['account']
    next if account.nil?

    date = item['date']
    year_month = "#{date.year}-#{date.month}"
    day = date.day.to_s

    amount = item['amount'].to_f
    balance = item['balance'].to_f
    description = item['description']

    datastore.insert_transaction(
        account,
        year_month,
        day,
        amount,
        balance,
        description
        )

    print '.' # progress indicator
    sleep(2)  # stay below Dynamo free-IOPs limit
end
puts ''
puts 'Done.'