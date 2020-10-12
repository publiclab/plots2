require 'test_helper'

class UtilsTest < ActiveSupport::TestCase
  include Utils
  
  test 'test_string_encryption' do
    data = "data_to_be_encrypted"
    encrypted_data = encrypt(data)
    assert_equal data, decrypt(encrypted_data)
    assert_equal data.class, decrypt(encrypted_data).class
  end

  test 'test_number_encryption' do
    data = 01
    encrypted_data = encrypt(data)
    assert_equal data, decrypt(encrypted_data)
    assert_equal data.class, decrypt(encrypted_data).class
  end

  test 'test_float_encryption' do
    data = 1.1
    encrypted_data = encrypt(data)
    assert_equal data, decrypt(encrypted_data)
    assert_equal data.class, decrypt(encrypted_data).class
  end

  test 'test_boolean_encryption' do
    data = true
    encrypted_data = encrypt(data)
    assert_equal data, decrypt(encrypted_data)
    assert_equal data.class, decrypt(encrypted_data).class
  end

  test 'test_array_encryption' do
    data = [1, 2, 3]
    encrypted_data = encrypt(data)
    assert_equal data, decrypt(encrypted_data)
    assert_equal data.class, decrypt(encrypted_data).class
  end

  test 'test_symbol_encryption' do
    data = :key
    encrypted_data = encrypt(data)
    assert_equal data, decrypt(encrypted_data)
    assert_equal data.class, decrypt(encrypted_data).class
  end

  test 'test_hashes_encryption' do
    data = { :key => "value" }
    encrypted_data = encrypt(data)
    assert_equal data, decrypt(encrypted_data)
    assert_equal data.class, decrypt(encrypted_data).class
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
