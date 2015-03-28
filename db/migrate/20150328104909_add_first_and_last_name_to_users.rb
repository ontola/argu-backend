class AddFirstAndLastNameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :first_name, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string
    add_column :users, :birthday, :date
    add_column :users, :postal_code, :string

    User.all.find_each do |u|
      names = (u.profile.name || '').split(' ')
      u.update_column :first_name, names[0]
      if names.length > 2
        u.update_column :middle_name, names[1..(names.length-2)].join(' ')
      end
      u.update_column :last_name, names.last
    end
  end

  def down
    remove_column :users, :first_name
    remove_column :users, :middle_name
    remove_column :users, :last_name
    remove_column :users, :birthday
    remove_column :users, :postal_code
  end
end
