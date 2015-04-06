module CommentsHelper
  include DropdownHelper

  def comment_items(resource, comment)
    link_items = []
    if policy(comment).trash?
      link_items << link_item(t('trash'), polymorphic_url([resource, comment]), data: {confirm: t('destroy_confirmation'), method: 'delete', 'skip-pjax' => 'true'}, fa: 'trash')
    end
    if policy(comment).destroy?
      link_items << link_item(t('destroy'), polymorphic_url([resource, comment], wipe: true), data: {confirm: t('destroy_confirmation'), method: 'delete', 'skip-pjax' => 'true'}, fa: 'close')
    end
    dropdown_options(t('menu'), [{items: link_items}], fa: 'fa-gear')
  end
end
