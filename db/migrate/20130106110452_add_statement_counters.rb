class AddStatementCounters < ActiveRecord::Migration
  def up
  	add_column :statements, :pro_count, :integer, default: 0
  	add_column :statements, :con_count, :integer, default: 0

  end

  def down
  end
end
