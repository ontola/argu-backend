module QuestionsHelper
  include DropdownHelper

  def question_items(question)
    if active_for_user?(:notifications, current_user)
      divided = true
      link_items = []
      if current_profile.following?(@question)
        link_items << link_item(t('forums.unfollow'), follows_path(question_id: question.id), fa: 'times', divider: 'top', data: {method: 'delete', 'skip-pjax' => 'true'})
      else
        link_items << link_item(t('forums.follow'), follows_path(question_id: question.id), fa: 'check', divider: 'top', data: {method: 'create', 'skip-pjax' => 'true'})
      end
      dropdown_options('question', [{items: link_items}], fa: 'fa-gear')
    end
  end
end
