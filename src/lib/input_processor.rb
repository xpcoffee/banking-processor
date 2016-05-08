require_relative 'file_handler'
require_relative 'mysql_handler'
require_relative '../configuration/config'

class InputProcessor
    def initialize(toothless)
        @toothless = toothless
    end

    def config
        @config ||= BankingConfig.new
    end

    def file
        @file ||= FileHandler.new
    end

    def db
        @db ||= MySQLHandler.new(config)
    end

    def counter
        @counter ||= 0
    end

    def process(path)
        puts "Selecting MySQL database..."
        db.use_database(config.database)

        puts "Inserting entries into table..."
        file.for_contents(path) { |line| process_line(line) }
        puts "Done. Processed #{counter} entries."
    end

    def process_line(line)
        if begins_with_date(line)
            data = line.split(config.data_delimiter)

            account = config.account
            date = data[0].strip
            amount = data[1].strip
            balance = data[2].strip
            description = data[3].strip

            if @toothless
                puts "#{date} #{account} #{amount} #{balance} #{description}"
                return
            end

            db.insert_transaction(
                date,
                account,
                amount,
                balance,
                description
                )

            @counter = counter + 1
        end
    end

    private

    def begins_with_date(str)
        str =~ /^[0-9]{4}\/[0-9]{2}\/[0-9]{2}/
    end

end
