class AddAttributesToForums < ActiveRecord::Migration
  def up
    add_column :forums, :bio, :text, default: '', null: false
    add_column :forums, :tags, :text, default: '', null: false
  end
end
