class AddCounterColumnsToArguments < ActiveRecord::Migration
  def change
    add_column :statements, :votes_abstain_count, :integer, default: 0, null: false
    add_column :arguments, :votes_abstain_count, :integer, default: 0, null: false
  end
end
