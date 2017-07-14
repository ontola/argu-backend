# frozen_string_literal: true
module CommentsHelper
  include DropdownHelper

  def comment_items(resource, comment)
    link_items = []
    resource_policy = policy(comment)
    if resource_policy.update?
      link_items << link_item(t('edit'),
                              polymorphic_url_for_action(:edit, [resource, comment], {}),
                              data: {comment_id: comment.id, turbolinks: 'false'},
                              fa: 'edit')
    end
    if resource_policy.destroy?
      link_items << link_item(t('destroy'),
                              polymorphic_url([resource, comment], destroy: true),
                              data: {confirm: t('destroy_confirmation'), method: 'delete', turbolinks: 'false'},
                              fa: 'close')
    end
    if resource.is_trashable? && resource_policy.trash?
      if comment.is_trashed?
        link_items << link_item(t('untrash'),
                                polymorphic_url([:untrash, resource, comment]),
                                data: {confirm: t('untrash_confirmation'), method: 'put', turbolinks: 'false'},
                                fa: 'eye')
      else
        link_items << link_item(t('trash'),
                                polymorphic_url([resource, comment]),
                                data: {confirm: t('trash_confirmation'), method: 'delete', turbolinks: 'false'},
                                fa: 'trash')
      end
    end
    dropdown_options(t('menu'), [{items: link_items}], fa: 'fa-ellipsis-v')
  end

  def comment_form_label(comment)
    comment.persisted? ? t('save') : t('reply')
  end
end
