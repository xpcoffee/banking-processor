require 'yaml'
require_relative 'io/encryption_handler'

module BankingProcessor
  class Config
    def initialize
      @config = load_yaml
    end

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
      @encryption_handler ||= BankingProcessor::IO::EncryptionHandler.new(encryption_key_path, encryption_iv_path)
    end

    # App config
    def dryrun
      @dryrun ||= config['app']['dryrun']
    end

    def balance_file
      @balance_file ||= config['app']['balance_file']
    end

    def breakdown_file
      @breakdown_file ||= config['app']['breakdown_file']
    end

    # MySQL config
    def user
      @user ||= config['mysql']['user']
    end

    def host
      @host ||= config['mysql']['host']
    end

    def pass
      @pass ||= config['mysql']['pass']
    end

    def database
      @database ||= config['mysql']['database']
    end

    def table
      @table ||= config['mysql']['table']
    end

    # Bank config
    def account
      @account ||= config['bank']['account']
    end

    # AWS config
    def aws_region
      @aws_region = config['aws']['region']
    end

    def aws_access_key
      @aws_access_key = config['aws']['access_key']
    end

    def aws_secret_key
      @aws_secret_key = config['aws']['secret_key']
    end

    def aws_ca_bundle
      @aws_ca_bundle = "#{config['aws']['ca_bundle']}"
    end

    def s3_bucket
      @s3_bucket = config['aws']['s3_bucket']
    end

    # Input file config
    def data_delimiter
      @data_delimiter ||= ','
    end

    private

    # Config logic
    def determine_root
      current_path = File.dirname(__FILE__)
      File.join(current_path, '../../../')
    end

    def load_yaml
      encrypted = File.read("#{config_root}/config.yaml.enc")
      yaml = encryption_handler.decrypt(encrypted)
      YAML.load(yaml)
    end

    def config
      @config
    end
  end
end
