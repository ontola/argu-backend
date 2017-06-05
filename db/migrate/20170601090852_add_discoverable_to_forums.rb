class AddDiscoverableToForums < ActiveRecord::Migration[5.0]
  def up
    add_column :forums, :discoverable, :boolean, default: true, null: false

    Forum.hidden.update_all(discoverable: false)
  end

  def down
    remove_column :forums, :discoverable, :boolean
  end
end
