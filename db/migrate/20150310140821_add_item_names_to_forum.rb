class AddItemNamesToForum < ActiveRecord::Migration
  def change
    add_column :forums, :uses_alternative_names, :boolean, default: false, null: false
    add_column :forums, :questions_title, :string
    add_column :forums, :questions_title_singular, :string
    add_column :forums, :motions_title, :string
    add_column :forums, :motions_title_singular, :string
    add_column :forums, :arguments_title, :string
    add_column :forums, :arguments_title_singular, :string
  end
end
