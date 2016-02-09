class ChangeBannerContentToText < ActiveRecord::Migration
  def up
    change_column :banners, :content, :text
  end

  def down
    change_column :banners, :content, :string
  end
end
