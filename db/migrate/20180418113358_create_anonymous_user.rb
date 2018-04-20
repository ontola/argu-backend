class CreateAnonymousUser < ActiveRecord::Migration[5.1]
  def change
    User.find_via_shortname('anonymous').shortname.update!(shortname: 'anonymous1')
    User.create!(
      id: User::ANONYMOUS_ID,
      first_name: 'Anonymous',
      email: 'anonymous@argu.co',
      profile: Profile.new(id: Profile::ANONYMOUS_ID),
      shortname: Shortname.new(shortname: 'anonymous'),
      password: SecureRandom.hex(32)
    )
  end
end
