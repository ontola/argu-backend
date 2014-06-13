class Votes < ActiveRecord::Migration
  def up
    create_table :avotes do |t|
      t.references :voteable, polymorphic: true
      t.references :voter,    polymorphic: true
      t.integer :for, default: 0, null: false
      t.timestamps
    end

    change_table :statements do |t|
      t.integer :vote_pro_count,     default: 0, null: false
      t.integer :vote_con_count,     default: 0, null: false
      t.integer :vote_neutral_count, default: 0, null: false
    end
  end

  def down
    drop_table :avotes
    remove_column :statements, :vote_pro_count
    remove_column :statements, :vote_con_count
    remove_column :statements, :vote_neutral_count
  end
end
