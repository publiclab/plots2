require 'test_helper'

class UtilsTest < ActiveSupport::TestCase
  include Utils

  test 'test_encrypt_decrypt_success' do
    data = "data_to_be_encrypted"
    encrypted_data = encrypt(data)
    assert_equal data, decrypt(encrypted_data)
  end

  test 'test_decryption_failure' do
    data = "data_to_be_encrypted"
    encrypted_data = encrypt(data)
    invalid_encrypted_data = encrypted_data + "invalid_data"
    assert_raise ActiveSupport::MessageVerifier::InvalidSignature do
      decrypt(invalid_encrypted_data)
    end
  end
end
