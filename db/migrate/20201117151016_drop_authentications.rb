class DropAuthentications < ActiveRecord::Migration[6.0]
  def change
    drop_table :authentications
    drop_table :sessions
  end
end
