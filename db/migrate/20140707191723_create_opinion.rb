class CreateOpinion < ActiveRecord::Migration
  def up
    create_table :opinions do |t|
      t.string :title
      t.text :content
      t.boolean :is_trashed
      t.integer :votes_count
      t.boolean :pro
      t.references :statement
    end
  end

  def down
    drop_table :opinions
  end
end
