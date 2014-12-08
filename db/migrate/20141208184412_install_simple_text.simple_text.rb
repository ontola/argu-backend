# This migration comes from simple_text (originally 20141208184215)
class InstallSimpleText < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :name, unique: true
      t.string :title
      t.text :contents

      t.timestamps
    end
  end
end
