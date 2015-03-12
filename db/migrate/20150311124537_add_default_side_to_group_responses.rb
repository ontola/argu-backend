class AddDefaultSideToGroupResponses < ActiveRecord::Migration
  def change
    change_column :group_responses, :side, :integer, default: 0
  end
end
