class AddTitleToStatements < ActiveRecord::Migration
  def change
    add_column :statements, :title, :string
  end
end
