class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.string :job_id
      t.datetime :published_at
      t.integer :publishable_id
      t.string :publishable_type
      t.string :channel
    end
  end
end
