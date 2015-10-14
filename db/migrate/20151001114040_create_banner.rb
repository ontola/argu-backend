class CreateBanner < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.string :type
      t.belongs_to :forum
      t.integer :publisher_id
      t.string :title
      t.string :content
      t.integer :cited_profile_id
      t.string :cited_avatar
      t.string :cited_name
      t.string :cited_function
      t.integer :audience, default: 0, null: false
      t.integer :sample_size, default: 100, null: false
      t.boolean :dismissable, default: true, null: false
      t.timestamp :publish_at, default: nil

      t.timestamps null: false
    end
    add_foreign_key :banners, :forums, on_delete: :cascade
    add_index :banners, :forum_id
    add_index :banners, [:forum_id, :publish_at]
  end
end
