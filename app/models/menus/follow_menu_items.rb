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

    def follow_menu_icon(follow_type)
      case follow_type
      when 'never'
        'fa-bell-slash-o'
      when 'reactions'
        'fa-bell'
      else
        'fa-bell-o'
      end
    end

    def follow_menu_items(opts = {})
      follow_types = opts.delete(:follow_types) || %i[news reactions never]
      menu_item(
        :follow,
        policy: :follow_items?,
        policy_resource: user,
        description: I18n.t('notifications.receive.title'),
        image: -> { follow_menu_icon(follow_type) },
        link_opts: opts,
        menus: -> { follow_types.map { |type| follow_menu_item(type, follow, follow_type) } }
      )
    end

    def follow_menu_item(type, follow, follow_type)
      if type == :never
        method = follow && 'DELETE'
        href = follow && follow_url(follow)
      else
        method = 'POST'
        href = follows_url(gid: resource.uuid, follow_type: type)
      end
      image = follow_type == type.to_s ? 'fa-circle' : 'fa-circle-o'
      action = resource.action(user_context, :"follow_#{type}")
      menu_item(type, action: action, href: href, image: image, link_opts: {data: {remote: true, method: method}})
    end
  end
end
