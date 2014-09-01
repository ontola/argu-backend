class DropCardsFromArgu < ActiveRecord::Migration
  def change
    drop_table :card_pages
    drop_table :cards
  end
end
