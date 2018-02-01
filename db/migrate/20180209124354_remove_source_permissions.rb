class RemoveSourcePermissions < ActiveRecord::Migration[5.1]
  def change
    PermittedAction.where(resource_type: 'Source').destroy_all
  end
end
