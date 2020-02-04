class DropAnnouncements < ActiveRecord::Migration[5.2]
  def change
    drop_table :announcements
  end
end
