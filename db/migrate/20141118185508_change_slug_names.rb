class ChangeSlugNames < ActiveRecord::Migration
  def change
    rename_column :motions, :organisation_id, :forum_id
    rename_column :forums, :display_name, :name
    add_column :forums, :slug, :string
    add_column :profiles, :slug, :string
  end
end
