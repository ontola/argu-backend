class ConvertIdentityTokenAndSecret < ActiveRecord::Migration[5.0]
  ENCRYPTOR_1 = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE_1'])
  ENCRYPTOR_1439 = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE_1439'])
  ENCRYPTOR_4015 = ActiveSupport::MessageEncryptor.new(ENV['SECRET_KEY_BASE'])

  def change
    Identity.where(user_id: nil).destroy_all
    Identity.find_each do |i|
      convert_identity(i)
    end
  end

  private

  def convert_identity(i)
    encryptor = if i.id >= 4015
                  ENCRYPTOR_4015
                elsif i.id >= 1439
                  ENCRYPTOR_1439
                else
                  ENCRYPTOR_1
                end
    i.access_token = encryptor.decrypt_and_verify(i.attributes['access_token'])
    i.save!
  end
end
