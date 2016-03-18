class AddStatementsCountToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :statements_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :organisations, :statements_count
  end
end
