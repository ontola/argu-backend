# frozen_string_literal: true
module Menus
  module FollowMenuItems
    def follow_menu_items(opts = {})
      follow_types = opts.delete(:follow_types) || %i(news reactions never)
      follow_type = user.following_type(resource.edge)
      icon = case follow_type
             when 'never'
               'fa-bell-slash-o'
             when 'reactions'
               'fa-bell'
             else
               'fa-bell-o'
             end
      menu_item(
        :follow,
        description: I18n.t('notifications.receive.title'),
        image: icon,
        link_opts: opts,
        menus: follow_types.map do |type|
          menu_item(
            type,
            href: follows_path(gid: resource.edge.id, follow_type: type),
            image: follow_type == type.to_s ? 'fa-circle' : 'fa-circle-o',
            link_opts: {
              data: {method: type == :never ? 'DELETE' : 'POST'}
            }
          )
        end
      )
    end
  end
end
