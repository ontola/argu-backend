class AddBioLongToForums < ActiveRecord::Migration
  def change
    add_column :forums, :bio_long, :text, default: ''
  end
end