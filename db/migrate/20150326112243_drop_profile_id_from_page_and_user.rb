class DropProfileIdFromPageAndUser < ActiveRecord::Migration
  def up
    remove_column :pages, :profile_id
    remove_column :users, :profile_id
  end

  def down
    add_column :pages, :profile_id, :integer
    add_column :users, :profile_id, :integer

    User.all.find_each do |u|
      u.update_column :profile_id, u.profile.try(:id)
    end

    Page.all.find_each do |p|
      p.update_column :profile_id, p.profile.try(:id)
    end
  end
end
