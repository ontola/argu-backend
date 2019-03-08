class CreateContainerNodeGrants < ActiveRecord::Migration[5.2]
  def change
    argu_page = Page.find_via_shortname('argu')

    show_page_blog_post = GrantSet.find_by(root_id: argu_page.uuid, title: 'show_page_blog_post')
    show_page_blog_post.grants.destroy_all
    show_page_blog_post.destroy

    PermittedAction
      .where(resource_type: 'ORIForum')
      .update_all("resource_type = 'OpenDataPortal', title = replace(title, 'ori_forum', 'open_data_portal')")

    @actions = HashWithIndifferentAccess.new
    %w[create show update destroy trash].each do |action|
      @actions["blog_#{action}"] =
        PermittedAction.create!(
          title: "blog_#{action}",
          resource_type: 'Blog',
          parent_type: '*',
          action: action.split('_').first
        )
    end

    GrantSet.where(root_id: nil).find_each do |grant_set|
      actions = [@actions[:blog_show]]
      actions << [@actions[:blog_update], @actions[:blog_destroy]] if grant_set.title == 'administrator'
      actions << [@actions[:blog_create], @actions[:blog_update], @actions[:blog_destroy]] if grant_set.title == 'staff'
      grant_set.permitted_actions << actions
      grant_set.save!(validate: false)
    end

    blog = Blog.create!(
      display_name: 'Blog',
      shortname: Shortname.new(shortname: 'blog', root: argu_page),
      parent: argu_page,
      creator: argu_page.profile,
      publisher: argu_page.publisher,
      public_grant: :participator,
      is_published: true
    )

    argu_page.blog_posts.find_each { |b| b.update(parent: blog) }
  end
end
