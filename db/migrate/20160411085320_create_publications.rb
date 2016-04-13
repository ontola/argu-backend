class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.string :job_id
      t.datetime :published_at
      t.integer :publishable_id
      t.string :publishable_type
      t.string :channel
      t.integer :creator_id, null: false
      t.integer :publisher_id
    end
  end
end
