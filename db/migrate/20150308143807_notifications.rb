class Notifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :profile
      t.belongs_to :activity
      t.datetime :read_at
      t.timestamps
    end
  end
end
