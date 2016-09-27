class SetForumVisibilityDefaultToHidden < ActiveRecord::Migration[5.0]
  def change
    change_column :forums, :visibility, :integer, default: Forum.visibilities[:hidden]
  end
end
