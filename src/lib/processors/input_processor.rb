require_relative '../handlers/file_handler'
require_relative '../handlers/mysql_handler'
require_relative '../handlers/config_handler'

class InputProcessor
    def initialize(dry = nil)
        @dryrun = dry unless dry.nil?
    end

    def config
        @config ||= BankingConfig.new
    end

    def dryrun
        @dryrun ||= config.dryrun
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
        puts "====================================================="
        puts "Inserting data from #{File.basename(path)} into MySQL"
        puts "====================================================="

        db.use_database(config.database)
        puts "Selected database #{config.database}"

        file.for_contents(path) { |line| process_line(line) }
        puts "Proccessing complete. Processed #{counter} entries."
    end

    def process_line(line)
        if begins_with_date(line)
            data = line.split(config.data_delimiter)

            account = config.account
            date = data[0].strip
            amount = data[1].strip
            balance = data[2].strip
            description = data[3].strip

            if dryrun
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
