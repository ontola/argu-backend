class ChangeOrganisationPublicityTypes < ActiveRecord::Migration
  def change
    remove_column :organisations, :public
    remove_column :organisations, :listed
    remove_column :organisations, :requestable
    add_column :organisations, :application_form, :integer, null: false, default: 0
    add_column :organisations, :public_form, :integer, null: false, default: 0
  end
end
