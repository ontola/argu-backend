class DefaultVauesForOpinions < ActiveRecord::Migration
  def up
    change_column :opinions, :is_trashed, :boolean, default: false
    change_column :opinions, :votes_count, :integer, default: 0
    change_column :opinions, :pro, :boolean, default: false
  end
end
