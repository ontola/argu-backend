class AddAnnouncements < ActiveRecord::Migration
  def up
    create_table :announcements do |t|
      t.integer :publisher_id
      t.string :title
      t.text :content
      t.integer :audience, default: 0, null: false
      t.integer :sample_size, default: 100, null: false
      t.boolean :dismissable, default: true, null: false
      t.timestamp :publish_at, default: nil

      t.timestamps null: false
    end
    add_index :announcements, :publish_at
    add_index :announcements, [:publish_at, :sample_size, :audience]
  end

  def down
    drop_table :announcements
  end
end
