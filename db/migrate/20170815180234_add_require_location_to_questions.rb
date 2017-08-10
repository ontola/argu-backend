class AddRequireLocationToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :require_location, :bool, default: false, null: false
  end
end
