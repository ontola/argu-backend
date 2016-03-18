class DropOpinions < ActiveRecord::Migration
  def change
    drop_table :opinions
    remove_column :motions, :opinion_pro_count
    remove_column :motions, :opinion_con_count
  end
end
