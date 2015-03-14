class AddSideToGroupResponses < ActiveRecord::Migration
  def change
    add_column :group_responses, :side, :integer, default: 0
  end
end
