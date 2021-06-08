class AddDisplayNameToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :display_name, :string

    User.where(hide_last_name: true).update_all('display_name = first_name')
    User.where(hide_last_name: false).update_all("display_name = concat_ws(' ', first_name, middle_name, last_name)")
    User.where(display_name: '').update_all(display_name: nil)
    User.connection.update(
      'UPDATE users '\
      'SET display_name = shortnames.shortname '\
      'FROM shortnames '\
      "WHERE shortnames.owner_type = 'User' "\
      'AND shortnames.owner_id = users.uuid '\
      'AND users.display_name IS NULL'
    )
  end
end
