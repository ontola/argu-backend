module QuestionsHelper
  include DropdownHelper

  def question_items(question)
    link_items = []
    if policy(question).update?
      link_items << link_item(t('edit'), edit_question_path(question), fa: 'pencil')
    end
    if policy(question).trash?
      link_items << link_item(t('trash'), question_path(question), data: {confirm: t('trash_confirmation'), method: 'delete', 'skip-pjax' => 'true'}, fa: 'trash')
    end
    if policy(question).destroy?
      link_items << link_item(t('destroy'), question_path(question, destroy: true), data: {confirm: t('destroy_confirmation'), method: 'delete', 'skip-pjax' => 'true'}, fa: 'close')
    end
    if current_profile && active_for_user?(:notifications, current_user)
      if current_profile.following?(question)
        link_items << link_item(t('forums.unfollow'), follows_path(question_id: question.id), fa: 'bell-slash', data: {method: 'delete', 'skip-pjax' => 'true'})
      else
        link_items << link_item(t('forums.follow'), follows_path(question_id: question.id), fa: 'bell', data: {method: 'create', 'skip-pjax' => 'true'})
      end
    end
    dropdown_options(t('menu'), [{items: link_items}], fa: 'fa-gear')
  end
end
