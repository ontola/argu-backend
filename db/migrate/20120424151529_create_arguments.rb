class CreateArguments < ActiveRecord::Migration
  def self.up
    change_table :arguments do |t|
      t.string :title
      t.change :type, :string
    end
  end
end
