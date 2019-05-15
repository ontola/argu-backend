# frozen_string_literal: true

class BlogMenuList < ContainerNodeMenuList
  has_action_menu link_opts: {triggerClass: 'btn--transparant'}
  has_follow_menu link_opts: {triggerClass: 'btn--transparant'}
  has_share_menu link_opts: {triggerClass: 'btn--transparant'}
  has_navigation_menu
end
