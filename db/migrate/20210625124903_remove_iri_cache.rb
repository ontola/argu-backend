class RemoveIRICache < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :iri_cache
  end
end
