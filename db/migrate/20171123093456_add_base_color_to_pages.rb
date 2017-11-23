class AddBaseColorToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :base_color, :string
  end
end
