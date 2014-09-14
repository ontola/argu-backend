class AddWebUrlToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :web_url, :string
  end
end
