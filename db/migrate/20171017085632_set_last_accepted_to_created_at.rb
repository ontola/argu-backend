class SetLastAcceptedToCreatedAt < ActiveRecord::Migration[5.1]
  def up
    User.update_all('last_accepted = created_at')
  end
end
