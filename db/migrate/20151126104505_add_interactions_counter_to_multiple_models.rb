class AddInteractionsCounterToMultipleModels < ActiveRecord::Migration
  def up
    add_column :questions, :interactions_count, :integer, default: 0, null: false
    add_column :motions, :interactions_count, :integer, default: 0, null: false
    add_column :arguments, :interactions_count, :integer, default: 0, null: false
    add_column :comments, :interactions_count, :integer, default: 0, null: false
  end

  def down
    remove_column :questions, :interactions_count
    remove_column :motions, :interactions_count
    remove_column :arguments, :interactions_count
    remove_column :comments, :interactions_count
  end
end
