class CreateShortname < ActiveRecord::Migration
  def up
    create_table :shortnames do |t|
      t.string :shortname
      t.references :owner, polymorphic: true
      t.timestamps
    end
    add_index :shortnames, :shortname, unique: true
    add_index :shortnames, [:owner_id, :owner_type], unique: true

    Forum.all.find_each do |f|
      Shortname.create owner: f, shortname: f.read_attribute(:web_url)
    end
    User.all.find_each do |u|
      Shortname.create owner: u, shortname: u.read_attribute(:username)
    end
    Page.all.find_each do |p|
      Shortname.create owner: p, shortname: p.read_attribute(:web_url)
    end
  end

  def down
    drop_table :shortnames
  end
end
