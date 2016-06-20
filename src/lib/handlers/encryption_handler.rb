require 'openssl'
require 'base64'

# This class provides methods for encrypting and decrypting strings.
# Encryption is AES 128 CBC
# It requires the paths to the encryption key and initialization-vector.
class EncryptionHandler
    def initialize(key_path, iv_path)
        @key_path = key_path
        @iv_path = iv_path
    end

    def key
        @key ||= Base64.decode64(File.read(@key_path))
    end

    def iv
        @iv ||= Base64.decode64(File.read(@iv_path))
    end

    # Encrypts a string, then base64 encodes it.
    def encrypt(string)
        aes = cipher
        encrypted = aes.update(string) + aes.final
        Base64.encode64(encrypted)
    end

    # Decrypts a base64 encoded string.
    def decrypt(base64_string)
        encrypted = Base64.decode64(base64_string)
        aes = decipher
        aes.update(encrypted) + aes.final
    end

    # Creates and configures a new cipher for encryption.
    def cipher
        aes = OpenSSL::Cipher::AES.new(128, :CBC)
        aes.encrypt
        aes.key = key
        aes.iv = iv
        return aes
    end

    # Creates and configures a new cipher for decryption.
    def decipher
        aes = OpenSSL::Cipher::AES.new(128, :CBC)
        aes.decrypt
        aes.key = key
        aes.iv = iv
        return aes
    end
end