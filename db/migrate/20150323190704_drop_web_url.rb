class DropWebUrl < ActiveRecord::Migration
  def change
    remove_column :forums, :web_url
    remove_column :pages, :web_url
  end
end
