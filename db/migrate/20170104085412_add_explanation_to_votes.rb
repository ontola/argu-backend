class AddExplanationToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :explanation, :text
    add_column :votes, :explained_at, :datetime
  end
end
