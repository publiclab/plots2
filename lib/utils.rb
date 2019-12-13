module Utils
  def get_encryption_key()
    return Rails.application.secrets.secret_key_base[0..31]
  end

  def encrypt(data)
    encryption_key = get_encryption_key()
    crypt = ActiveSupport::MessageEncryptor.new(encryption_key)
    encrypted_data = crypt.encrypt_and_sign(data)
    return encrypted_data
  end

  def decrypt(data)
    encryption_key = get_encryption_key()
    crypt = ActiveSupport::MessageEncryptor.new(encryption_key)
    decrypted_data = crypt.decrypt_and_verify(data)
    return decrypted_data
  end
end
