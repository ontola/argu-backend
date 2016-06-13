class AddHasDraftsToUser < ActiveRecord::Migration
  def up
    add_column :users, :has_drafts, :boolean, default: false, null: false
    User
      .where(id: (BlogPost.unpublished.pluck(:publisher_id) + Project.unpublished.pluck(:publisher_id)).uniq)
      .update_all(has_drafts: true)
  end

  def down
    remove_column :users, :has_drafts
  end
end
