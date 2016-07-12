class RemoveAlternativeNames < ActiveRecord::Migration
  def change
    remove_column :forums, :uses_alternative_names, :boolean, default: false, null: false
    remove_column :forums, :questions_title_singular, :string
    remove_column :forums, :questions_title, :string
    remove_column :forums, :motions_title_singular, :string
    remove_column :forums, :motions_title, :string
    remove_column :forums, :arguments_title_singular, :string
    remove_column :forums, :arguments_title, :string

    remove_column :questions, :uses_alternative_names, :boolean, default: false, null: false
    remove_column :questions, :motions_title_singular, :string
    remove_column :questions, :motions_title, :string
  end
end
