module CommentsHelper
  include DropdownHelper

  def comment_items(resource, comment)
    link_items = []
    if comment.is_trashed?
      if policy(comment).trash?
        link_items << link_item(t('untrash'), polymorphic_url([:untrash, resource, comment]), data: {confirm: t('untrash_confirmation'), method: 'put', turbolinks: 'false'}, fa: 'eye')
      end
      if policy(comment).destroy?
        link_items << link_item(t('destroy'), polymorphic_url([resource, comment], destroy: true), data: {confirm: t('destroy_confirmation'), method: 'delete', turbolinks: 'false'}, fa: 'close')
      end
    else
      if policy(comment).trash?
        link_items << link_item(t('trash'), polymorphic_url([resource, comment]), data: {confirm: t('trash_confirmation'), method: 'delete', turbolinks: 'false'}, fa: 'trash')
      end
    end
    dropdown_options(t('menu'), [{items: link_items}], fa: 'fa-gear')
  end

  def comment_form_label(comment)
    comment.persisted? ? t('edit') : t('reply')
  end
end
