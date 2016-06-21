class UsePagesAsEdgeRoot < ActiveRecord::Migration
  def up
    add_foreign_key :pages, :profiles, column: :owner_id
    remove_column :edges, :fragment
    remove_column :edges, :parent_fragment

    Page.find_each do |page|
      Edge.create(
        owner: page,
        user: page.owner.profileable,
        created_at: page.created_at,
        updated_at: page.updated_at)
    end

    Forum.find_each do |forum|
      forum.edge.update(parent: forum.page.edge)
    end

    Edge.find_each do |edge |
      edge.commit_path
    end

    destroy_duplicate_follows
    Follow.update_all(followable_type: 'Edge')
  end

  def down
    remove_foreign_key :pages, column: :owner_id
    add_column :edges, :fragment, :string
    add_column :edges, :parent_fragment, :string

    Edge.where("owner_type != 'Page'").find_each do |edge |
      puts edge.owner.identifier
      edge.fragment = edge.owner.identifier
      edge.parent_fragment = edge.owner_type == 'Forum' ? nil : edge.owner.parent_model.identifier
      edge.parent_id = edge.owner_type == 'Forum' ? nil : edge.owner.parent_model
      ancestors = edge.ancestors.map { |a| a.owner.identifier }
      if ancestors.size > 1
        edge.path = ancestors.detect{|i| i.include? 'forums'}
        %w(memberships projects phases blog_posts questions motions
           arguments group_responses comments votes).each do |klass|
          edge.path.concat ".#{ancestors.detect{|i| i.include? klass}}" if ancestors.detect{|i| i.include? klass}
        end
        edge.path.concat ".#{edge.owner.identifier}"
      else
        edge.path = edge.owner.identifier
      end
      edge.save
    end

    Edge.where(owner_type: 'Page').destroy_all

    change_column_null :edges, :fragment, false
    change_column_null :edges, :parent_fragment, false

    Follow.update_all(followable_type: 'Ltree::Models::Edge')
  end

  private

  def destroy_duplicate_follows
    edge = Follow.where(followable_type: 'Edge').pluck(:followable_id, :follower_id)
    ltree = Follow.where(followable_type: 'Ltree::Models::Edge').pluck(:followable_id, :follower_id)
    intersection = ltree & edge
    return unless intersection.present?
    prepared_intersections = intersection.map { |t| "(#{t[0]}, #{t[1]})" }.join(', ')
    Follow
      .where(followable_type: 'Ltree::Models::Edge')
      .where("(followable_id, follower_id) IN (#{prepared_intersections})")
      .destroy_all
  end
end
