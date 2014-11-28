class AddVotesConCountToArguments < ActiveRecord::Migration
  def change
    add_column :arguments, :votes_con_count, :integer, default: 0, null: false
  end
end
