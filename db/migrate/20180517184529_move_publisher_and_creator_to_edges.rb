class MovePublisherAndCreatorToEdges < ActiveRecord::Migration[5.1]
  def change
    add_column :edges, :creator_id, :integer
    rename_column :edges, :user_id, :publisher_id
    add_foreign_key :edges, :profiles, column: :creator_id

    (Edge.unscoped.pluck(:owner_type).uniq - %w[Page Forum]).each do |klass|
      Edge.connection.update(
        "UPDATE edges SET creator_id = #{klass.tableize}.creator_id FROM #{klass.tableize} "\
        "WHERE edges.owner_id = #{klass.tableize}.id AND edges.owner_type = '#{klass}'"
      )
    end

    %w[Page Forum].each do |klass|
      Edge.unscoped.connection.update(
        "UPDATE edges SET creator_id = profiles.id FROM users "\
        "INNER JOIN profiles ON profiles.profileable_id = users.id AND profiles.profileable_type = 'User'"\
        "WHERE edges.owner_type = '#{klass}' AND edges.publisher_id = users.id"
      )
    end

    change_column_null :edges, :creator_id, false
  end
end
