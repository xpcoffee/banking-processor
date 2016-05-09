require_relative 'encryption_handler'
class BankingConfig
    # Application roots
    def app_root
        @app_root ||= determine_root
    end

    def config_root
        @config_root ||= File.join(app_root, 'configuration')
    end

    def sql_root
        @sql_root ||= File.join(app_root, 'src/sql')
    end

    def unencrypted_sql_root
        @unencrypted_sql_root ||= File.join(app_root, 'src/unencrypted-sql')
    end

    def output_path
        @output_path ||= File.join(app_root, 'output')
    end
    # Encryption
    def encryption_path
        @encryption_path ||= File.join(app_root, 'secrets')
    end

    def encryption_key_path
        @encryption_key_path ||= File.join(encryption_path, 'key')
    end

    def encryption_iv_path
        @encryption_iv_path ||= File.join(encryption_path, 'iv')
    end

    def encryption_handler
        @encryption_handler ||= EncryptionHandler.new(encryption_key_path, encryption_iv_path)
    end

    # MySQL config
    def user
        @user ||= encryption_handler.decrypt('5qN8BrJ9HpIKsRhJoabMDg==')
    end

    def host
        @host ||= encryption_handler.decrypt('QGr/pvqHvsY+9y+HUz8K6g==')
    end

    def pass
        @pass ||= encryption_handler.decrypt('rbvlRZppycxsb9erFyKsXQ==')
    end

    def database
        @database ||= encryption_handler.decrypt('G5MvDavNVPRXNUhpF0YdoA==')
    end

    def table
        @table ||= encryption_handler.decrypt('HpdK+Cb6O5F6KjA0pO8pJw==')
    end

    # Input file config
    def data_delimiter
        @data_delimiter ||= ','
    end

    # Bank config
    def account
        @account ||= encryption_handler.decrypt('PnIGoZdoDxL6K3z+WFd34A==')
    end

    private

    # Config logic
    def determine_root
        current_path = File.dirname(__FILE__)
        File.join(current_path, '../../../')
    end

    def load_yaml

    end
end
