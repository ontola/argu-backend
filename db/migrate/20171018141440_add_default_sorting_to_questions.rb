class AddDefaultSortingToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :default_sorting, :integer, default: 0, null: false
  end
end
