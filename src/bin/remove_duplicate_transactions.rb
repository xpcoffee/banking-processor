require_relative '../lib/banking_processor/io/preety_output'
require_relative '../lib/banking_processor/config'
require_relative '../lib/banking_processor/datastore/ddb_handler'

preety = BankingProcessor::IO::PreetyOutput.new
config = BankingProcessor::Config.new
ddb = BankingProcessor::Datastore::DynamoDBHandler.new(config).client

account = config.default_account
table = config.transaction_table(account)

scan_options = {
  table_name: table
}

preety.heading("Scanning DynamoDB table")
resp = ddb.scan(scan_options)
transactions = resp.items
puts "Number of transactions: #{transactions.size}"

# determine number of duplicates
found_transaction = {}
duplicated_transactions = []

transactions.each do |transaction|
  balance = transaction['balance']
  year_month = transaction['year-month']

  integer_balance = balance.to_i
  key = "#{year_month}/#{integer_balance}"

  if found_transaction[key]
    duplicated_transactions.push(transaction)
  else
    found_transaction[key] = true
  end
end

puts "Number of duplicate transactions: #{duplicated_transactions.size}"

preety.heading("Deleting duplicates from transaction table")
duplicated_transactions.each do |transaction|
  year_month = transaction['year-month']
  balance = transaction['balance'].to_f

  delete_options = {
    table_name: table,
    key: {
      "year-month" => year_month,
      "balance" => balance
    }
  }

  begin
    ddb.delete_item(delete_options);
    print '.'
  rescue => e
    STDERR.puts "[ERROR] Unable to delete transaction #{year_month}/#{balance}. #{e.class}: #{e.message}"
  end

  sleep(2); # stay under free call limit
end

puts ''
