class AllowNullForArgumentsMotionId < ActiveRecord::Migration[5.0]
  def change
    change_column_null :arguments, :motion_id, true
  end
end
