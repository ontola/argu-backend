class AddMembersCountToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :members_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :organisations, :members_count
  end
end
