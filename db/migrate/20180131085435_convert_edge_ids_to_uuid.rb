class ConvertEdgeIdsToUuid < ActiveRecord::Migration[5.1]
  def up
    execute 'ALTER TABLE edges DROP CONSTRAINT edges_pkey CASCADE;'
    rename_column :edges, :id, :fragment
    change_column_default :edges, :fragment, nil
    add_column :edges, :id, :uuid, default: 'uuid_generate_v4()', null: false
    execute 'ALTER TABLE edges ADD PRIMARY KEY (id);'
    add_column :edges, :root_id, :uuid
    Edge.reset_column_information

    Edge.roots.each do |root|
      root.self_and_descendants.update_all(root_id: root.id)
    end

    change_column_null :edges, :root_id, false

    add_index :edges, %i[root_id fragment], unique: true
    add_index :favorites, %i[user_id edge_id], unique: true
    add_index :follows, %i[followable_id followable_type]
    add_index :follows, %i[follower_type follower_id followable_type followable_id], unique: true, name: 'index_follower_followable'
    add_index :grant_resets, %i[edge_id resource_type action], unique: true
    add_index :grants, %i[group_id edge_id], unique: true
    add_index :rules, %i[branch_id]

    rename_column :edges, :parent_id, :parent_fragment

    [
      [:decisions, :decisionable_id, false],
      [:favorites, :edge_id, false],
      [:follows, :followable_id, false],
      [:grant_resets, :edge_id, false],
      [:rules, :branch_id, false],
      [:grants, :edge_id, false],
      [:publications, :publishable_id, true],
      [:activities, :recipient_edge_id, true],
      [:activities, :trackable_edge_id, true]
    ].each do |table, column, null|
      puts "Processing #{table}"
      old_column = "old_#{column}"
      rename_column table, column, old_column
      add_column table, column, :uuid
      table.to_s.classify.constantize.reset_column_information
      table.to_s.classify.constantize.where("#{old_column} IS NOT NULL").find_each do |record|
        record.update_column(column, Edge.find_by(fragment: record.send(old_column)).id)
      end
      remove_column table, old_column
      change_column_null table, column, null
      add_foreign_key table, :edges, column: column
    end
  end
end
