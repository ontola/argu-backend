class AddAuditDataToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :audit_data, :json
  end
end
