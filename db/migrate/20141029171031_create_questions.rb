class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title, default: ''
      t.text :content, default: ''
      t.references :organisation
      t.integer :creator_id
      t.boolean :is_trashed, default: false
      t.integer :motions_count, default: 0
      t.integer :votes_pro_count, default: 0
      t.integer :votes_con_count, default: 0
      t.timestamps
    end
  end
end
