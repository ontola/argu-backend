class RenameUserOrganisationToMembership < ActiveRecord::Migration
  def change
    rename_table :user_organisations, :memberships
  end
end
