class DropAccessTokens < ActiveRecord::Migration[5.1]
  def up
    drop_table :access_tokens
  end
end
