class MoveShortnamesToEdges < ActiveRecord::Migration[5.1]
  def change
    pre_count = Shortname.count
    Shortname.pluck(:owner_type).uniq.map do |klass|
      Shortname.joins("LEFT JOIN #{klass.tableize} ON shortnames.owner_type = '#{klass}' AND shortnames.owner_id = #{klass.tableize}.id WHERE shortnames.owner_type = '#{klass}' AND #{klass.tableize}.id IS NULL").destroy_all
    end
    puts "Destroyed #{pre_count - Shortname.count} orphane shortnames"

    add_column :users, :uuid, :uuid, default: 'uuid_generate_v4()', null: false

    add_index :users, :uuid, unique: true

    add_column :shortnames, :owner_uuid, :uuid

    Shortname.connection.update('UPDATE shortnames SET owner_type = \'Edge\', owner_id = edges.id, owner_uuid = edges.uuid FROM edges WHERE edges.owner_id = shortnames.owner_id AND edges.owner_type = shortnames.owner_type')
    Shortname.connection.update('UPDATE shortnames SET owner_uuid = users.uuid FROM users WHERE users.id = shortnames.owner_id AND shortnames.owner_type = \'User\'')

    remove_column :shortnames, :owner_id

    rename_column :shortnames, :owner_uuid, :owner_id

    change_column_null :shortnames, :owner_id, false

    add_index :shortnames, [:owner_id, :owner_type], unique: true
  end
end
