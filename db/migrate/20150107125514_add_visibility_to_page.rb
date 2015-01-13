class AddVisibilityToPage < ActiveRecord::Migration
  def change
    add_column :pages, :visibility, :integer, default: 1
  end
end
