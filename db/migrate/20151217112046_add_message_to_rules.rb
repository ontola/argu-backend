class AddMessageToRules < ActiveRecord::Migration
  def up
    add_column :rules, :message, :string
  end

  def down
    remove_column :rules, :message
  end
end
