class AddCommentToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :comment, :string
  end
end
