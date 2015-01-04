class AddForumIdToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :forum_id, :integer
    Vote.reset_column_information
    Vote.all.each do |v|
      if v.voteable.present?
        if v.voteable.class == Argument
          v.update_column :forum_id, v.voteable.motion.forum_id
        else
          v.update_column :forum_id, v.voteable.forum_id
        end
      else
        v.destroy
      end
    end
    change_column_null :votes, :forum_id, true
  end
end
