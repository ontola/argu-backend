class AddTimestampsToOpinion < ActiveRecord::Migration
  def up
    add_timestamps :opinions
  end

  def down
    remove_timestamps :opinions
  end
end
