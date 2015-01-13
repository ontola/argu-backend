class AddOwnerToPage < ActiveRecord::Migration
  def change
    add_column :pages, :owner, :integer

    Page.update_all(owner: User.find_by_username(:fletcher91).profile.id)

    change_column_null :pages, :owner, true
  end
end
