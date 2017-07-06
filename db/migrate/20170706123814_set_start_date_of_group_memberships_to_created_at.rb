class SetStartDateOfGroupMembershipsToCreatedAt < ActiveRecord::Migration[5.0]
  def up
    GroupMembership.update_all('start_date = created_at')
  end
end
