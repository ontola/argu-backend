class AddAccessTokensToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_tokens, :text
  end
end
