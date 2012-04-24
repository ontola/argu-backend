class CreateArguments < ActiveRecord::Migration
  def change
    create_table :arguments do |t|
      t.string :content
      t.integer :type

      t.timestamps
    end
  end
end
