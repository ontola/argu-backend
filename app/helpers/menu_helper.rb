# frozen_string_literal: true

module MenuHelper
  # Generates a dropdown (cr)Update Delete menu for use in the profile bar.
  # @author Fletcher91 <thom@argu.co>
  # @param resource [Model] The model the actions should be done upon
  # @param additional_items [Array] Additionals `dropdown items` to be merged at the top of the menu.
  def crud_menu_item(resource, additional_items = [])
    options = crud_menu_options(resource, additional_items)
    return if options.empty?
    content_tag :li do
      content_tag :ul do
        react_component 'HyperDropdown',
                        options,
                        prerender: true
      end
    end
  end

  def forum_menu_item(resource)
    feed_item =
      if controller_name == 'feed'
        link_item(t('overview'), url_for(resource), fa: 'th-large')
      elsif policy(resource).feed?
        link_item(t('feed'), url_for([resource, :feed]), fa: 'feed')
      end
    settings_item = link_item(
      t('forums.settings.title'),
      settings_forum_path(resource),
      fa: 'gear',
      data: {turbolinks: false_unless_iframe}
    )
    options = dropdown_options(
      t('menu'),
      [{items: [settings_item, feed_item]}],
      fa: 'fa-ellipsis-v',
      triggerClass: 'btn--transparant'
    )

    return if options.empty?
    content_tag :li, class: 'float-right' do
      content_tag :ul do
        react_component 'HyperDropdown',
                        options,
                        prerender: true
      end
    end
  end

  private

  # Generates the dropdown via {dropdown_options}.
  # @private
  # @see crud_menu_item
  def crud_menu_options(resource, additional_items = [])
    link_items = [].concat(additional_items).compact
    resource_policy = policy(resource)
    link_items.append(crud_menu_decision_option(resource))
    link_items.append(crud_menu_comments_option(resource))
    link_items.append(crud_menu_feed_option(resource, resource_policy))
    link_items.append(crud_menu_new_blog_post_option(resource, resource_policy))
    link_items.append(crud_menu_edit_option(resource, resource_policy))
    link_items.append(crud_menu_statisics_option(resource, resource_policy))
    link_items.concat(crud_menu_trash_options(resource, resource_policy))
    dropdown_options(t('menu'), [{items: link_items.compact}], fa: 'fa-ellipsis-v')
  end

  def crud_menu_comments_option(resource)
    return unless [Motion, Question].include?(resource.class)
    link_item(
      t('comments.menu', count: resource.children_count(:comments)),
      polymorphic_url([resource, :comments]),
      fa: 'comments-o'
    )
  end

  def crud_menu_decision_option(resource)
    return unless resource.is_a?(Motion) && policy(resource.last_or_new_decision(true)).update?
    link_item(
      t('decisions.menu'),
      motion_decisions_path(resource),
      fa: 'gavel'
    )
  end

  def crud_menu_edit_option(resource, resource_policy)
    return unless resource_policy.update?
    link_item(t('edit'), polymorphic_url([:edit, resource]), fa: 'edit')
  end

  def crud_menu_feed_option(resource, resource_policy)
    return unless resource_policy.feed?
    link_item(t('feed'), url_for([resource, :feed]), fa: 'feed')
  end

  def crud_menu_new_blog_post_option(resource, resource_policy)
    return unless resource_policy.create_child?(:blog_posts)
    link_item(t('blog_posts.type_new'), polymorphic_url([:new, resource, :blog_post]), fa: blog_post_icon)
  end

  def crud_menu_statisics_option(resource, resource_policy)
    return unless resource.is_a?(Motion) && resource_policy.statistics?
    link_item(t('statistics'), vote_event_url(resource.default_vote_event), fa: 'bar-chart-o')
  end

  def crud_menu_trash_options(resource, resource_policy)
    link_items = []
    if resource_policy.destroy?
      link_items << link_item(t('destroy'),
                              polymorphic_url(resource, destroy: true),
                              data: {confirm: t('destroy_confirmation'), method: 'delete', turbolinks: 'false'},
                              fa: 'close')
    end
    return link_items unless resource.is_trashable? && resource_policy.trash?
    if resource.is_trashed?
      link_items << link_item(t('untrash'),
                              polymorphic_url([:untrash, resource]),
                              data: {confirm: t('untrash_confirmation'), method: 'put', turbolinks: 'false'},
                              fa: 'eye')
    else
      link_items << link_item(t('trash'),
                              polymorphic_url([:delete, resource]),
                              data: {remote: true},
                              fa: 'trash')
    end
    link_items
  end
end
