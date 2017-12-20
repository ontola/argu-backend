# frozen_string_literal: true

module Menus
  module FollowMenuItems
    def follow_menu_items(opts = {})
      follow_types = opts.delete(:follow_types) || %i[news reactions never]
      follow = user.follow_for(resource.edge)
      follow_type = follow&.follow_type || 'never'
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
          href = type == :never ? follow && follow_path(follow) : follows_url(gid: resource.edge.id, follow_type: type)
          menu_item(
            type,
            href: href,
            image: follow_type == type.to_s ? 'fa-circle' : 'fa-circle-o',
            link_opts: {
              data: {remote: true, method: type == :never ? 'DELETE' : 'POST'}
            }
          )
        end
      )
    end
  end
end
