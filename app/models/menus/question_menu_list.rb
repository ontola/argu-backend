# frozen_string_literal: true
class QuestionMenuList < MenuList
  include SettingsHelper, Menus::FollowMenuItems, Menus::ShareMenuItems, Menus::ActionMenuItems
  cattr_accessor :defined_menus
  has_menus %i(actions follow share)

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: [couple_motion_link, comments_link, activity_link, new_update_link, edit_link, trash_and_destroy_links]
    )
  end

  def follow_menu
    follow_menu_items
  end

  def share_menu
    share_menu_items
  end

  def couple_motion_link
    menu_item(
      :couple_motion,
      image: 'fa-link',
      href: new_question_answer_url(question_answer: {question_id: resource}),
      policy: :create_child?,
      policy_arguments: [:question_answers, question: resource]
    )
  end
end
