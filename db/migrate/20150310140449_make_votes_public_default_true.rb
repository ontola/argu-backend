class MakeVotesPublicDefaultTrue < ActiveRecord::Migration
  def change
    change_column :profiles, :are_votes_public, :boolean, default: true
  end
end
