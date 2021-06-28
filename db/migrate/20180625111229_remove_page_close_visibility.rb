class RemovePageCloseVisibility < ActiveRecord::Migration[5.1]
  def change
    Property.where(predicate: NS.argu[:visibility].to_s).where(integer: 2).update_all(integer: 3)
  end
end
