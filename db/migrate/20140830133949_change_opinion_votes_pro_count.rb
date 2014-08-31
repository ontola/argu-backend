class ChangeOpinionVotesProCount < ActiveRecord::Migration
  def change
    rename_column :opinions, :votes_count, :votes_pro_count
  end
end
