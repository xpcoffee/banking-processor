require 'json'
require_relative '../lib/banking_processor/io/preety_output'
require_relative '../lib/banking_processor/config'
require_relative '../lib/banking_processor/datastore/ddb_handler'
require_relative '../lib/banking_processor/datastore/dynamodb/transaction_handler'

BACKUP_FILE = 'transaction_items.bak'

def year_month_to_date(year_month)
  #[year, month] = year_month.split('-')
  Date.parse("#{year_month}-01");
end

def iterate_through_transactions(transactions)
  transactions.each do |transaction|
    yield( transaction['year-month'],
      transaction['amount'],
      transaction['balance'],
      transaction['description'] )
  end
end

preety = BankingProcessor::IO::PreetyOutput.new
config = BankingProcessor::Config.new
ddb = BankingProcessor::Datastore::DynamoDBHandler.new(config).client
transactions = BankingProcessor::Datastore::DynamoDB::TransactionHandler.new(ddb, config)

account = config.default_account

# -----

preety.heading("Scanning DynamoDB table")
items = transactions.scan(account)

puts "Number of transactions: #{items.size}"
preety.end_section

# -----

preety.heading("Backing up transactions")

backup_path = File.join(config.output_path, BACKUP_FILE)
puts "Backup path: #{backup_path}"
File.open(backup_path,'w') do |file|
  file.write(items.to_json)
end

puts "Done."
preety.end_section

# -----

preety.heading("Replacing transactions")

iterate_through_transactions(items) do |year_month, amount, balance, description|
  date = year_month_to_date(year_month)
  new_balance = balance.to_i

  transactions.delete_transaction(account, date, balance)
  sleep(1)
  transactions.put_transaction(account, date, amount, new_balance, description)
  print '.'
  sleep(1)
end
puts ''

puts 'Done.'
preety.end_section
