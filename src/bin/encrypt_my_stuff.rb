require 'base64'
require_relative '../lib/handlers/config_handler'
require_relative '../lib/handlers/encryption_handler'
require_relative '../lib/handlers/file_handler'

# This script encrypts all .sql files in the unencrypted sql directory and places them within the encrypted sql directory.
class SQLEncrypter
    def initialize
        @config = BankingConfig.new
        @encryption_handler = EncryptionHandler.new(config.encryption_key_path,config.encryption_iv_path)
        @file_handler = FileHandler.new
    end

    def encrypt_sql
        directories = ['balance', 'monthly-breakdown']
        directories.each do |dir|
            unencrypted_path = "#{config.unencrypted_sql_root}/#{dir}"
            encrypted_path = "#{config.sql_root}/#{dir}"
            files = "*.sql"
            encrypt_files_in_directory(unencrypted_path, encrypted_path, files)
        end
    end

    def encrypt_yaml
        unencrypted_path = "#{config.config_root}"
        encrypted_path = "#{config.config_root}"
        files = "*.yaml"
        encrypt_files_in_directory(unencrypted_path, encrypted_path, files)
    end

    def encrypt_files_in_directory(unencrypted_path, encrypted_path, files)
        file_handler.for_files("#{unencrypted_path}/#{files}") do |filename|
            sql_query = File.read(filename)
            encrypted_query = encryption_handler.encrypt(sql_query)

            output = File.open("#{encrypted_path}/#{File.basename(filename)}.enc", "w")
            output << encrypted_query
            output.close

            puts "Encrypted #{File.basename(filename)}"
        end
    end

    # getters
    def config
        @config
    end

    def encryption_handler
        @encryption_handler
    end

    def file_handler
        @file_handler
    end
end

encrypter = SQLEncrypter.new
encrypter.encrypt_sql
encrypter.encrypt_yaml