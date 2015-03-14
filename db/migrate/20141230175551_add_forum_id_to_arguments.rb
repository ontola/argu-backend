class AddForumIdToArguments < ActiveRecord::Migration
  def change
    add_column :arguments, :forum_id, :integer
    Argument.reset_column_information
    Argument.all.each do |v|
      if v.motion.present?
          v.update_column :forum_id, v.motion.forum_id
      else
        v.destroy
      end
    end
    change_column_null :arguments, :forum_id, true
  end
end
