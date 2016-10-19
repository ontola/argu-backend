class AddTimestampsToPlacements < ActiveRecord::Migration[5.0]
  def change
    add_column :placements, :created_at, :datetime
    add_column :placements, :updated_at, :datetime
  end
end
