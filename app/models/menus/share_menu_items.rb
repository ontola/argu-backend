# frozen_string_literal: true

module Menus
  module ShareMenuItems
    def share_menu_items(opts = {})
      return menu_item(:share, menus: []) unless resource.is_published?

      url = polymorphic_url(resource, only_path: false)
      items = [invite_link]
      if resource.edge.is_public?
        items.concat([
                       facebook_share_link(url),
                       twitter_share_link(url),
                       linkedin_share_link(url),
                       whatsapp_share_link(url)
                     ])
        items << email_share_link(url) unless policy(resource).invite?
      end
      menu_item(
        :share,
        image: 'fa-share-alt',
        link_opts: opts.merge(iri: url),
        menus: items
      )
    end

    def invite_link
      menu_item(
        :invite,
        image: 'fa-share',
        link_opts: {data: {remote: 'true'}},
        href: url_for([resource, :invite]),
        policy: :invite?
      )
    rescue NoMethodError
      nil
    end

    def facebook_share_link(url)
      menu_item(
        :facebook,
        type: 'fb_share',
        image: 'fa-facebook',
        link_opts: {target: '_blank'},
        href: ShareHelper.facebook_share_url(url)
      )
    end

    def twitter_share_link(url)
      menu_item(
        :twitter,
        type: 'twitter_share',
        image: 'fa-twitter',
        link_opts: {target: '_blank'},
        href: ShareHelper.twitter_share_url(url, title: resource.display_name)
      )
    end

    def linkedin_share_link(url)
      menu_item(
        :linked_in,
        type: 'linked_in_share',
        image: 'fa-linkedin',
        link_opts: {target: '_blank'},
        href: ShareHelper.linkedin_share_url(url, title: resource.display_name)
      )
    end

    def email_share_link(url)
      menu_item(
        :email,
        image: 'fa-envelope',
        href: ShareHelper.email_share_url(url, title: resource.display_name)
      )
    end

    def whatsapp_share_link(url)
      menu_item(
        :whatsapp,
        type: 'mobile_link',
        image: 'fa-whatsapp',
        href: ShareHelper.whatsapp_share_url(url)
      )
    end
  end
end
