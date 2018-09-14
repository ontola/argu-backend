# frozen_string_literal: true

module Menus
  module ShareMenuItems
    def share_menu_items(opts = {})
      return menu_item(:share, menus: -> { [] }) unless resource.is_published?

      url = resource.iri
      menu_item(
        :share,
        image: 'fa-share-alt',
        link_opts: opts.merge(iri: url),
        menus: -> { share_menu_links(url) }
      )
    end

    def invite_link
      menu_item(
        :invite,
        image: 'fa-share',
        link_opts: {data: {remote: 'true'}},
        href: invites_iri(resource),
        policy: :invite?
      )
    end

    def copy_share_link(url)
      menu_item(
        :copy,
        action: NS::ONTOLA["actions/copyToClipboard?value=#{url}"],
        item_type: 'copy',
        image: 'fa-clipboard',
        href: url
      )
    end

    def facebook_share_link(url)
      menu_item(
        :facebook,
        item_type: 'fb_share',
        image: 'fa-facebook',
        link_opts: {target: '_blank'},
        href: RDF::URI.intern(ShareHelper.facebook_share_url(url))
      )
    end

    def twitter_share_link(url)
      menu_item(
        :twitter,
        item_type: 'twitter_share',
        image: 'fa-twitter',
        link_opts: {target: '_blank'},
        href: RDF::URI.intern(ShareHelper.twitter_share_url(url, title: resource.display_name))
      )
    end

    def no_social_media_notice
      menu_item(:no_social_media, item_type: 'notice')
    end

    def linkedin_share_link(url)
      menu_item(
        :linked_in,
        item_type: 'linked_in_share',
        image: 'fa-linkedin',
        link_opts: {target: '_blank'},
        href: RDF::URI.intern(ShareHelper.linkedin_share_url(url, title: resource.display_name))
      )
    end

    def email_share_link(url)
      menu_item(
        :email,
        image: 'fa-envelope',
        href: RDF::URI.intern(ShareHelper.email_share_url(url, title: resource.display_name))
      )
    end

    def whatsapp_share_link(url)
      menu_item(
        :whatsapp,
        item_type: 'mobile_link',
        image: 'fa-whatsapp',
        href: RDF::URI.intern(ShareHelper.whatsapp_share_url(url))
      )
    end

    private

    def is_public?
      user_context
        .grant_tree_for(resource)
        .granted_group_ids(resource)
        .include?(Group::PUBLIC_ID)
    end

    def share_menu_links(url)
      items = [invite_link]
      if is_public?
        items.concat([
                       facebook_share_link(url),
                       twitter_share_link(url),
                       linkedin_share_link(url),
                       whatsapp_share_link(url)
                     ])
        items << email_share_link(url) unless policy(resource).invite?
        items << copy_share_link(url)
      else
        items.concat(
          [
            copy_share_link(url),
            no_social_media_notice
          ]
        )
      end
      items
    end
  end
end
