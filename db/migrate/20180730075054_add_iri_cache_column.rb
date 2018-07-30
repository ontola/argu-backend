class AddIRICacheColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :edges, :iri_cache, :string
    add_column :users, :iri_cache, :string
  end
end
