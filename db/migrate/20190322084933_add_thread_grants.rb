class AddThreadGrants < ActiveRecord::Migration[5.2]
  def change
    @actions = HashWithIndifferentAccess.new
    %w[create show update destroy trash].each do |action|
      @actions["topic_#{action}"] =
        PermittedAction.create!(
          title: "topic_#{action}",
          resource_type: 'Topic',
          parent_type: '*',
          action: action.split('_').first
        )
    end

    GrantSet.where(root_id: nil).find_each do |grant_set|
      actions = [@actions[:topic_show]]
      actions << [@actions[:topic_create]] if grant_set.title == 'initiator'
      if grant_set.title == 'moderator'
        actions << [@actions[:topic_create], @actions[:topic_update], @actions[:topic_trash]]
      end
      if grant_set.title == 'administrator'
        actions << [@actions[:topic_create], @actions[:topic_update], @actions[:topic_trash]]
      end
      if grant_set.title == 'staff'
        actions << [@actions[:topic_create], @actions[:topic_update], @actions[:topic_trash], @actions[:topic_destroy]]
      end
      grant_set.permitted_actions << actions
      grant_set.save!(validate: false)
    end

    Forum.find_each { |f| ActsAsTenant.with_tenant(f.root) { Widget.send(:create_new_topic, f) } }
    Widget.discussions.update_all(position: 5)
  end
end
