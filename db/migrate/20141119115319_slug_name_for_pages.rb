class SlugNameForPages < ActiveRecord::Migration
  def change
    change_column :pages, :display_name, :name
    add_column :pages, :slug, :string, unique: true
  end
end
