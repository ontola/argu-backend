class AddCustomMotionNameToQuestions < ActiveRecord::Migration
  def up
    add_column :questions, :uses_alternative_names, :boolean, default: false, null: false
    add_column :questions, :motions_title_singular, :string
    add_column :questions, :motions_title, :string
  end

  def down
    remove_column :questions, :uses_alternative_names
    remove_column :questions, :motions_title_singular
    remove_column :questions, :motions_title
  end
end
