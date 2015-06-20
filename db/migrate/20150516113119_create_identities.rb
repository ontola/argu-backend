class CreateIdentities < ActiveRecord::Migration
  def up
    create_table :identities do |t|
      t.references :user, index: true
      t.string :provider
      t.string :uid
      t.string :access_token
      t.string :access_secret

      t.timestamps null: false
    end
    add_foreign_key :identities, :users

    add_column :users, :gender, :integer
    add_column :users, :hometown, :integer
    add_column :users, :timezone, :integer
  end

  def down
    drop_table :identities
  end
end
