class RemoveArgumentContentNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :arguments, :content, null: true
  end
end
