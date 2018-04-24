class MoveUnconfirmedVotesToPg < ActiveRecord::Migration[5.1]
  def change
    add_column :edges, :confirmed, :bool, null: false, default: false

    Edge.joins(user: :email_addresses).where('email_addresses.confirmed_at IS NOT NULL').update_all(confirmed: true)
  end
end
