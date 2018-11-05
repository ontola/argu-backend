class AddORIForumGrants < ActiveRecord::Migration[5.2]
  def change
    @actions = HashWithIndifferentAccess.new

    %w[create show update destroy trash].each do |action|
      @actions["ori_forum_#{action}"] =
        PermittedAction.create!(
          title: "ori_forum_#{action}",
          resource_type: 'ORIForum',
          parent_type: '*',
          action: action
        )
    end

    GrantSet::RESERVED_TITLES.each do |title|
      grant_set = GrantSet.find_by(title: title)
      grant_set.permitted_actions << @actions[:ori_forum_show]
      grant_set.save!(validate: false)
    end

    grant_set = GrantSet.find_by(title: 'staff')
    grant_set.permitted_actions << [@actions[:ori_forum_update], @actions[:ori_forum_destroy]]
    grant_set.save!(validate: false)
  end
end
