class GenerateForumPage < ActiveRecord::Migration
  def change
    create_table :forum_pages do |t|
      t.belongs_to :forum
      t.belongs_to :page
      t.integer :creator_id
    end
  end
end
