class MultipleProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :order, :integer, null: false, default: 0
  end
end
