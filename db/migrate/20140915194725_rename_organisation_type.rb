class RenameOrganisationType < ActiveRecord::Migration
  def change
    rename_column :organisations, :organisation_type, :scope
  end
end
