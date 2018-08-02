class CreateServiceUser < ActiveRecord::Migration[5.2]
  def change
    User.create!(
      id: User::SERVICE_ID,
      first_name: 'System',
      email: 'service_user@argu.co',
      profile: Profile.new(id: Profile::SERVICE_ID),
      shortname: Shortname.new(shortname: 'service1'),
      password: SecureRandom.hex(32),
      last_accepted: Time.current
    )
    Shortname.find_by(shortname: 'service1').update(shortname: 'service')
    Doorkeeper::AccessToken.where(scopes: 'service').update_all(resource_owner_id: User::SERVICE_ID)
  end
end
