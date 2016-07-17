require 'aws-sdk'

class DDBHandler
  def initialize(region, access_key, secret_key, ca_bundle)
    @ddb = Aws::DynamoDB::Client.new(
      region: region,
      access_key_id: access_key,
      secret_access_key: secret_key,
      ssl_ca_bundle: ca_bundle # Ruby SDK can't find path on Windows - need to set it explicitly
    )
  end

  def ddb
    @ddb
  end

  def get_tables
    resp = ddb.list_tables()
    return resp.table_names
  end

  def use_table(database)
    @table ||= database
  end

  def insert_transaction(date, account, amount, balance, description)
    raise '[ERROR] Table not set for DDB client.' if @table.nil?

    ddb.put_item({
      table_name: @table,
      item: {
        'date' => date,
        'balance' => balance,
        'amount' => amount,
        'description' => description
      }
      })
  end
end