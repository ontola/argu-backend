class CreateOpinions < ActiveRecord::Migration
  def change
    create_table :opinions do |t|
      t.integer     :motion_id,     null: false
      t.integer     :for,           null: false, default: 3
      t.integer     :creator_id,    null: false
      t.integer     :publisher_id,  null: false
      t.integer     :forum_id,      null: false
      t.boolean     :archived,      null: false, default: false
      t.text        :body,          null: false
      t.timestamps                  null: false
    end
    add_foreign_key :opinions, :motions
    add_foreign_key :opinions, :forums
    add_foreign_key :opinions, :users,    column: :publisher_id
    add_foreign_key :opinions, :profiles, column: :creator_id

    create_table :opinion_arguments do |t|
      t.integer :opinion_id,  index: true, null: false
      t.integer :argument_id, index: true
      t.integer :original_argument_id, index: true
    end
    add_foreign_key :opinion_arguments, :arguments
    add_foreign_key :opinion_arguments, :opinions
  end
end
