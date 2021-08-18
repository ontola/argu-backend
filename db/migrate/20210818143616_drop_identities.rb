class DropIdentities < ActiveRecord::Migration[6.0]
  def change
    drop_table :identities
  end
end
