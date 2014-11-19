class ISaidChangeToName < ActiveRecord::Migration
  def change
    rename_column :pages, :display_name, :name
  end
end
