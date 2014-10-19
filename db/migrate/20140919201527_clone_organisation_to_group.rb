class CloneOrganisationToGroup < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute('CREATE TABLE groups (LIKE organisations INCLUDING INDEXES);')
  end
end
