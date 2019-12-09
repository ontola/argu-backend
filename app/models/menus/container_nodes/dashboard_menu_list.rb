# frozen_string_literal: true

class DashboardMenuList < ContainerNodeMenuList
  has_action_menu link_opts: {triggerClass: 'btn--transparant'}
  has_follow_menu link_opts: {triggerClass: 'btn--transparant'}
  has_share_menu link_opts: {triggerClass: 'btn--transparant'}
end
