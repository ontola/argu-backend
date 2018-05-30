class DontAllowNullInActivities < ActiveRecord::Migration[5.1]
  def change
    change_column_null :activities, :trackable_type, false
    change_column_null :activities, :recipient_type, false
  end
end
