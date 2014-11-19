class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :website
      t.boolean :public
      t.boolean :listed
      t.boolean :requestable
      t.text :description
      t.string :slogan
      t.string :key_tags

      t.timestamps
    end
    add_attachment :forums, :profile_photo
  end
end
