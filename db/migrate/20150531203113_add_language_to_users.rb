class AddLanguageToUsers < ActiveRecord::Migration
  def up
    add_column :users, :language, :string, default: 'nl'
    add_column :users, :country, :string, default: 'NL'
  end

  def down
    remove_column :users, :language
    remove_column :users, :country
  end
end
