class CreateLtreeEdges < ActiveRecord::Migration
  def up
    add_foreign_key :forums, :pages
    create_table :edges do |t|
      t.integer :user_id, null: false
      t.string :fragment, null: false
      t.integer :parent_id
      t.string :parent_fragment
      t.integer :owner_id, null: false
      t.string :owner_type, null: false
      t.ltree :path
      t.timestamps null: false
    end
    add_foreign_key :edges, :users
    add_foreign_key :edges, :edges, column: :parent_id
    add_index :edges, [:owner_type, :owner_id], unique: true

    walk_all_data
  end

  def down
    drop_table :edges
    remove_foreign_key :forums, :pages
  end

  def walk_all_data
    Forum.find_each { |f| create_edge(f, f.page.owner.profileable) }
    Project.find_each { |p| create_edge(p) }
    Question.find_each { |q| create_edge(q) }
    Motion.find_each { |m| create_edge(m) }
    Argument.find_each { |a| create_edge(a) }
    Comment.find_each { |c| create_edge(c) }
    Phase.find_each { |p| create_edge(p) }
    BlogPost.find_each { |b| create_edge(b) }
    GroupResponse.find_each { |g| create_edge(g) }
    Membership.find_each do |m|
      create_edge(
        m,
        created_at: m.profile.created_at)
    end
    Vote.find_each { |v| create_edge(v) }
  end

  def create_edge(owner, user = nil, created_at: nil)
    say owner.identifier
    parent = !owner.is_a?(Forum) && owner.parent
    path = parent && parent.edge.path
    path ||= owner.identifier
    Edge.create(
      owner: owner,
      user: user || owner.publisher,
      fragment: owner.identifier,
      parent: parent && parent.edge,
      parent_fragment: parent && parent.identifier,
      path: path,
      created_at: created_at || owner.created_at,
      updated_at: created_at || owner.updated_at)
  end
end
