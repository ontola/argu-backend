class ChangeProfilesRelationToProfileable < ActiveRecord::Migration
  def up
    add_column :profiles, :profileable_type, :string
    add_column :profiles, :profileable_id, :integer

    add_index :profiles, [:profileable_type, :profileable_id], unique: true

    User.all.find_each do |u|
      u.profile.update_columns profileable_type: 'User', profileable_id: u.id
    end

    Page.all.find_each do |p|
      p.profile.update_columns profileable_type: 'Page', profileable_id: p.id
    end
  end

  def down
    remove_column :profiles, :profileable_type
    remove_column :profiles, :profileable_id
  end
end
