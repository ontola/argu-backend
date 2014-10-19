class AddOrganisationTypeToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :organisation_type, :integer, default: 0, null: false
  end
end
