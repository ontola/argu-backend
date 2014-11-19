class AddWebUrlToPagesForums < ActiveRecord::Migration
  def change
    add_column :pages, :web_url, :string, null: false, default: ''
    add_column :forums, :web_url, :string, null: false, default: ''
  end
end
