class AddNotNullToShortnames < ActiveRecord::Migration
  def change
    change_column :shortnames, :owner_id, :integer, null: false
    change_column :shortnames, :owner_type, :string, null: false
    change_column :shortnames, :shortname, :string, null: false
  end
end
