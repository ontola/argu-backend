class StatementBelongsToOrganisation < ActiveRecord::Migration
  def change
    add_belongs_to :statements, :organisation, index: true
  end
end
