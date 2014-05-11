class ChangeCardPagesCardsIdToCardId < ActiveRecord::Migration
  def up
    rename_column :card_pages, :cards_id, :card_id
  end

  def down
    rename_column :card_pages, :card_id, :cards_id
  end
end
