class CreateCards < ActiveRecord::Migration
  def up
    create_table :cards do |t|
      t.string :title
      t.string :url
      t.references :tags
      t.timestamps
    end

    create_table :card_pages do |t|
      t.references :cards
      t.string :title
      t.text :contents
      t.integer :page_index
      t.timestamps
    end
  end

  def down
    drop_table :cards
    drop_table :card_pages
  end
end
