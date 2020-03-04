class DropIRICacheFromEdges < ActiveRecord::Migration[6.0]
  def change
    remove_column :edges, :iri_cache
  end
end
