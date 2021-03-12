class AddForce2FaToGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :require_2fa, :boolean, default: false

    Group.staff&.update(require_2fa: true)
  end
end
