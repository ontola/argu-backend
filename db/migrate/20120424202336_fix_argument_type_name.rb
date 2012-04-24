class FixArgumentTypeName < ActiveRecord::Migration
  def up
    rename_column :arguments, :type, :argtype
  end

  def down
  end
end
