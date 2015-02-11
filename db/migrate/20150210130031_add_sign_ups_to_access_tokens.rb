class AddSignUpsToAccessTokens < ActiveRecord::Migration
  def change
    add_column :access_tokens, :sign_ups, :integer, default: 0
  end
end
