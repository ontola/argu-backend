class RemoveVoteMatches < ActiveRecord::Migration[5.2]
  def change
    drop_table :vote_matches
    drop_table :list_items
  end
end
