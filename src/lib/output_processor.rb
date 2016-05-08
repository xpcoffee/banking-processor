require_relative 'file_handler'
require_relative 'mysql_handler'
require_relative '../configuration/config'

class OutputProcessor
    def config
        @config ||= BankingConfig.new
    end

    def encryption_handler
        @encryption_handler = config.encryption_handler
    end

    def file_handler
        @file ||= FileHandler.new
    end

    def db
        @db ||= MySQLHandler.new(config)
    end

    def csv_data
        @csv_data ||= []
    end

    def export_balance_data_to_csv(output_file)
        puts "=============================="
        puts "Exporting balance data to .csv"
        puts "=============================="
        export_data_to_csv("#{config.sql_root}/balance/", output_file)
    end

    def export_breakdown_data_to_csv(output_file)
        puts "==================================="
        puts "Exporting monthly-breakdown to .csv"
        puts "==================================="
        export_data_to_csv("#{config.sql_root}/monthly-breakdown/", output_file)
    end

    private

    def export_data_to_csv(sql_path, output_file)
        data = get_data(sql_path)
        begin
            puts "Writing data to csv..."

            output = File.open("#{config.output_path}#{output_file}", "w")
            data.each do |query_data|
                output << "#{query_data.join(',')}\n"
            end

            puts "Write complete. Data exported to #{output_file}"
        ensure
            output.close
        end
    end

    def get_data(sql_path)
        @data= {}
        execute_sql_queries(sql_path) { |query_result|
            # Add headings, initialize arrays
            headings = query_result.fields
            headings.each do |heading|
                @data[heading] = []
            end

            # Add values
            query_result.each do |row|
                row.each do |k,v|
                    @data[k].push(v.nil? ? 0 : v)
                end
            end
        }
        return @data
    end

    # Execute all the sql queries in the SQL path
    # If the files are encrypted, decrypt them first
    def execute_sql_queries(sql_path)
        puts "Selecting MySQL database..."
        db.use_database(config.database)

        puts "Querying database..."
        file_handler.for_files("#{sql_path}*.sql") do |filename|
            puts 'Found unencrypted SQL query: ' + File.basename(filename)
            sql_query = File.read(filename)
            result = db.query(sql_query)
            yield(result)
        end

        file_handler.for_files("#{sql_path}*.enc") do |filename|
            puts 'Found encrypted SQL query: ' + File.basename(filename)
            contents = File.read(filename)
            sql_query = encryption_handler.decrypt(contents)
            result = db.query(sql_query)
            yield(result)
        end
    end
end