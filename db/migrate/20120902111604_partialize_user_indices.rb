class PartializeUserIndices < ActiveRecord::Migration
  def up
  	execute "DROP INDEX index_users_on_email"
  	execute "CREATE INDEX index_users_on_email 
            ON users (email) 
            WHERE email IS NOT NULL"
    execute "CREATE INDEX index_users_on_username 
            ON users (username) 
            WHERE username IS NOT NULL"
  end

  def down
  end
end
