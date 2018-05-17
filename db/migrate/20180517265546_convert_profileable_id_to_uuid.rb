class ConvertProfileableIdToUUID < ActiveRecord::Migration[5.1]
  def up
    add_column :profiles, :profileable_uuid, :uuid
    Profile.connection.update('UPDATE profiles SET profileable_uuid = users.uuid FROM users WHERE users.id = profiles.profileable_id AND profiles.profileable_type = \'User\'')
    Profile.connection.update('UPDATE profiles SET profileable_type = \'Edge\', profileable_uuid = edges.uuid FROM edges WHERE edges.owner_id = profiles.profileable_id AND edges.owner_type = profiles.profileable_type')
    remove_column :profiles, :profileable_id
    rename_column :profiles, :profileable_uuid, :profileable_id
    change_column_null :profiles, :profileable_id, false
    add_index :profiles, [:profileable_type, :profileable_id], unique: true
  end
end
