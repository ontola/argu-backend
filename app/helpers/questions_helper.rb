module QuestionsHelper
  include DropdownHelper

  def question_items(question)
    divided = true
    link_items = []
    if policy(question).update?
      link_items << link_item(t('edit'), edit_question_path(question), fa: 'pencil')
    end
    if active_for_user?(:notifications, current_user)
      if current_profile.following?(question)
        link_items << link_item(t('forums.unfollow'), follows_path(question_id: question.id), fa: 'times', divider: 'top', data: {method: 'delete', 'skip-pjax' => 'true'})
      else
        link_items << link_item(t('forums.follow'), follows_path(question_id: question.id), fa: 'check', divider: 'top', data: {method: 'create', 'skip-pjax' => 'true'})
      end
    end
    dropdown_options(t('menu'), [{items: link_items}], fa: 'fa-gear')
  end
end
