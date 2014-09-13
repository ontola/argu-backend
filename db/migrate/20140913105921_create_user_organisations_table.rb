class CreateUserOrganisationsTable < ActiveRecord::Migration
  def change
    create_table :user_organisations do |t|
      t.belongs_to :user
      t.belongs_to :organisation
    end
  end
end
