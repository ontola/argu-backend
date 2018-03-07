# frozen_string_literal: true

class QuestionMenuList < MenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems
  include Menus::ActionMenuItems
  cattr_accessor :defined_menus
  has_menus %i[actions follow share]

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: lambda {
        [
          couple_motion_link,
          comments_link,
          activity_link,
          new_update_link,
          edit_link,
          statistics_link,
          *trash_and_destroy_links,
          contact_link
        ]
      }
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
      policy_arguments: %i[question_answers]
    )
  end
end
