class AddIndicesToOrganisations < ActiveRecord::Migration
  def change
    add_index :organisations, :id
    add_index :organisations, :web_url
    add_index :organisations, :name
  end
end
