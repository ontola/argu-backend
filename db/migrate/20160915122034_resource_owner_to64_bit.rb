class ResourceOwnerTo64Bit < ActiveRecord::Migration[5.0]
  def up
    remove_column :oauth_access_tokens, :resource_owner_id
    add_column :oauth_access_tokens, :resource_owner_id, :string
  end
  
  def down
    remove_column :oauth_access_tokens, :resource_owner_id
    add_column :oauth_access_tokens, :resource_owner_id, :integer
  end
end
