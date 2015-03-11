class AddVotesPublicToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :are_votes_public, :boolean
  end
end
