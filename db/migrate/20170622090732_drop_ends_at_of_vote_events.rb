class DropEndsAtOfVoteEvents < ActiveRecord::Migration[5.0]
  def up
    remove_column :vote_events, :ends_at
  end
end

