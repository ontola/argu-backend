class RemoveFkFromAccessTokens < ActiveRecord::Migration
  def up
    remove_foreign_key :access_tokens, :profiles
  end
end
