class AddTimeStampsToGrantResets < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :grant_resets, null: true
  end
end
