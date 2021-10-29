class AddRequireConfirmationToGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :require_confirmation, :boolean, default: false, null: false

    Group.where(deletable: false).update_all(require_confirmation: true)
  end
end
