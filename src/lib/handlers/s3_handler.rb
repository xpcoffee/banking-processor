require 'rubygems'
require 'aws-sdk'

class S3Handler
    def initialize(region, access_key, secret_key, ca_bundle)
        @s3 = Aws::S3::Client.new(
            region: region,
            access_key_id: access_key,
            secret_access_key: secret_key,
            ssl_ca_bundle: ca_bundle # Ruby SDK can't find path on Windows - need to set it explicitly
        )
    end

    def s3
        @s3
    end

    def upload_file(file_path, bucket_name, key)
        begin
            File.open(file_path, 'rb') do |file|
              resp = s3.put_object(bucket: bucket_name, key: key, body: file)
            end
            puts "Upload complete. Key: #{key} Bucket: #{bucket_name}"
        rescue Aws::S3::Errors::ServiceError => e
            puts 'Unable to upload file: ' + e
        end
    end
end
