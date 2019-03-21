class ResetIris < ActiveRecord::Migration[5.2]
  def change
    Edge.update_all(iri_cache: nil)
    Widget.destroy_all
  end
end
