class DropStepups < ActiveRecord::Migration[5.0]
  def up
    drop_table :stepups
  end
end
