class AddForumIdToOpinions < ActiveRecord::Migration
  def change
    add_column :opinions, :forum_id, :integer
    Opinion.reset_column_information
    Opinion.all.each do |v|
      if v.motion.present?
        v.update_column :forum_id, v.motion.forum_id
      else
        v.destroy
      end
    end
    change_column_null :opinions, :forum_id, true
  end
end
