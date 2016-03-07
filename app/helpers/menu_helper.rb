module MenuHelper
  # Generates a dropdown (cr)Update Delete menu for use in the profile bar.
  # @author Fletcher91 <thom@argu.co>
  # @param resource [Model] The model the actions should be done upon
  # @param additional_items [Array] Additionals `dropdown items` to be merged at the top of the menu.
  def crud_menu_item(resource, additional_items = [])
    if current_user.present? && policy(resource).update?
      content_tag :li do
        content_tag :ul do
          react_component 'HyperDropdown',
                          crud_menu_options(resource, additional_items),
                          prerender: true
        end
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
    if resource.respond_to?(:blog_posts) # @TODO figure out how to do the authorization nicely
      link_items << link_item(t('blog_posts.type_new'), polymorphic_url([:new, resource, :blog_post]), fa: 'quote-left')
    end
    link_items << link_item(t('edit'), polymorphic_url([:edit, resource]), fa: 'edit') if resource_policy.update?
    link_items << link_item(t('log'), polymorphic_url([resource, :log]), fa: 'history') if resource_policy.log?
    if resource.is_trashed?
      if resource_policy.trash?
        link_items << link_item(t('untrash'),
                                polymorphic_url([:untrash, resource]),
                                data: {confirm: t('untrash_confirmation'), method: 'put', turbolinks: 'false'},
                                fa: 'eye')
      end
      if resource_policy.destroy?
        link_items << link_item(t('destroy'),
                                polymorphic_url(resource, destroy: true),
                                data: {confirm: t('destroy_confirmation'), method: 'delete', turbolinks: 'false'},
                                fa: 'close')
      end
    else
      if resource_policy.trash?
        link_items << link_item(t('trash'),
                                polymorphic_url(resource),
                                data: {confirm: t('trash_confirmation'), method: 'delete', turbolinks: 'false'},
                                fa: 'trash')
      end
    end
    dropdown_options(t('menu'), [{items: link_items}], fa: 'fa-ellipsis-v')
  end
end
