class CreateProperties < ActiveRecord::Migration[5.1]
  def change
    Edge.connection.update('UPDATE edges SET owner_type = arguments.type FROM arguments WHERE edges.owner_id = arguments.id AND edges.owner_type = \'Argument\'')

    create_table :properties do |t|
      t.timestamps
      t.uuid :edge_id, null: false
      t.string :predicate, null: false
      t.boolean :boolean
      t.string :string
      t.text :text
      t.datetime :datetime
      t.bigint :integer
      t.uuid :linked_edge_id
    end

  add_index :properties, :edge_id

    migrate_properties(
      'Page',
      [:visibility, :integer, NS::ARGU[:visibility]],
      [:last_accepted, :datetime, NS::ARGU[:lastAccepted]],
      [:base_color, :string, NS::ARGU[:baseColor]]
    )
    migrate_properties(
      'VoteEvent',
      [:starts_at, :datetime, NS::SCHEMA[:startDate]]
    )
    migrate_properties(
      'Motion',
      [:title, :string, NS::SCHEMA[:name]],
      [:content, :text, NS::SCHEMA[:text]]
    )
    migrate_properties(
      'Question',
      [:title, :string, NS::SCHEMA[:name]],
      [:content, :text, NS::SCHEMA[:text]],
      [:require_location, :boolean, NS::ARGU[:requireLocation]],
      [:default_sorting, :integer, NS::ARGU[:defaultSorting]]
    )
    migrate_properties(
      'Comment',
      [:body, :text, NS::SCHEMA[:text]]
    )
    ActiveRecord::Base.connection.execute(
      "INSERT INTO properties (created_at, updated_at, edge_id, predicate, linked_edge_id) SELECT current_timestamp, current_timestamp, edges.uuid, 'https://argu.co/ns/core#inReplyTo', linked_edges.uuid "\
        "FROM comments INNER JOIN edges ON edges.owner_id = comments.id AND edges.owner_type = 'Comment' INNER JOIN edges AS linked_edges ON linked_edges.owner_id = comments.parent_id AND linked_edges.owner_type = 'Comment' WHERE comments.parent_id IS NOT NULL"
    )
    migrate_properties(
      'Vote',
      [:for, :integer, NS::SCHEMA[:option]]
      )
    ActiveRecord::Base.connection.execute(
      "INSERT INTO properties (created_at, updated_at, edge_id, predicate, linked_edge_id) SELECT current_timestamp, current_timestamp, edges.uuid, 'https://argu.co/ns/core#explanation', linked_edges.uuid "\
        "FROM votes INNER JOIN edges ON edges.owner_id = votes.id AND edges.owner_type = 'Vote' INNER JOIN edges AS linked_edges ON linked_edges.owner_id = votes.comment_id AND linked_edges.owner_type = 'Comment' WHERE votes.comment_id IS NOT NULL"
    )
    migrate_properties(
      'Decision',
      [:content, :text, NS::SCHEMA[:text]],
      [:forwarded_group_id, :integer, NS::ARGU[:forwardedGroup]],
      [:forwarded_user_id, :integer, NS::ARGU[:forwardedUser]],
      [:state, :integer, NS::ARGU[:state]],
      [:step, :integer, NS::ARGU[:step]]
    )
    migrate_properties(
      'BlogPost',
      [:title, :string, NS::SCHEMA[:name]],
      [:content, :text, NS::SCHEMA[:text]]
    )
    migrate_properties(
      'Forum',
      [:name, :string, NS::SCHEMA[:name]],
      [:bio, :text, NS::SCHEMA[:description]],
      [:bio_long, :text, NS::SCHEMA[:text]],
      [:cover_photo_attribution, :string, NS::ARGU[:photoAttribution]],
      [:discoverable, :boolean, NS::ARGU[:discoverable]],
      [:locale, :string, NS::ARGU[:locale]],
      [:default_decision_group_id, :integer, NS::ARGU[:defaultDecisionGroupId]]
    )
    migrate_properties(
      'ConArgument',
      [:title, :string, NS::SCHEMA[:name]],
      [:content, :text, NS::SCHEMA[:text]]
    )
    migrate_properties(
      'ProArgument',
      [:title, :string, NS::SCHEMA[:name]],
      [:content, :text, NS::SCHEMA[:text]]
    )
  end

  def down
    drop_table :properties
  end

  private


  def migrate_properties(klass, *properties)
    properties.each do |column, type, predicate|
      puts "Migrate #{klass} #{predicate.to_s}"
      table = klass.include?('Argument') ? 'arguments' : klass.tableize
      ActiveRecord::Base.connection.execute(
        "INSERT INTO properties (created_at, updated_at, edge_id, predicate, #{type}) SELECT current_timestamp, current_timestamp, edges.uuid, '#{predicate.to_s}', #{table}.#{column} "\
        "FROM #{table} INNER JOIN edges ON edges.owner_id = #{table}.id AND edges.owner_type = '#{klass}' WHERE #{table}.#{column} IS NOT NULL"
      )
    end
  end
end
