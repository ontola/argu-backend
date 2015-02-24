class AddDeadlineToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :expires_at, :datetime
  end
end