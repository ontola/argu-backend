class AddGuestUser < ActiveRecord::Migration[6.0]
  def change
    Tenant.send(:create_system_user, User::GUEST_ID, Profile::GUEST_ID, 'guest', 'guest@argu.co')
  end
end
