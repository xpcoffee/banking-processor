require 'base64'
require_relative '../lib/banking_processor/config'
require_relative '../lib/banking_processor/io/encryption_handler'
require_relative '../lib/banking_processor/io/file_handler'

# This script encrypts all .sql files in the unencrypted sql directory and places them within the encrypted sql directory.
class Encrypter
    def initialize
        @config = BankingProcessor::Config.new
        @encryption_handler = BankingProcessor::IO::EncryptionHandler.new(config.encryption_key_path,config.encryption_iv_path)
        @file_handler = BankingProcessor::IO::FileHandler.new
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

encrypter = Encrypter.new
encrypter.encrypt_sql
encrypter.encrypt_yaml