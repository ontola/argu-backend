# frozen_string_literal: true

module Menus
  module FollowMenuItems
    private

    def follow
      @follow ||= user.follow_for(resource)
    end

    def follow_type
      @follow_type ||= follow&.follow_type || 'never'
    end

    def follow_menu_items(follow_types)
      follow_types ||= %i[news reactions never]
      items = follow_types.map { |type| follow_menu_item(type, follow, follow_type) }

      [menu_item(:follow_header, item_type: 'notice')] + items
    end

    def follow_menu_item(type, follow, follow_type)
      href = type == :never ? follow && follow_url(follow) : follows_url(gid: resource.uuid, follow_type: type)
      image = follow_type == type.to_s ? 'fa-circle' : 'fa-circle-o'
      action = resource.action(:"follow_#{type}", user_context)
      menu_item(type, action: action, href: href, image: image)
    end
  end
end
