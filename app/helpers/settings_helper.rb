# frozen_string_literal: true

module SettingsHelper
  def tab_icons # rubocop:disable Metrics/MethodLength
    {
      general: 'gear',
      advanced: 'gears',
      container_nodes: 'cubes',
      custom_menu_items: 'bars',
      delete: 'trash',
      grants: 'suitcase',
      groups: 'group',
      emails: 'envelope',
      forums: 'comments',
      privacy: 'lock',
      shortnames: 'external-link',
      banners: 'sticky-note',
      setting: 'sliders',
      sources: 'database',
      profile: 'user',
      notifications: 'bell',
      authentication: 'shield',
      members: 'users',
      invite: 'user-plus',
      bearer_invite: 'link',
      email_invite: 'send'
    }
  end

  def setting_item(tag, opts)
    opts[:image] ||= "fa-#{tab_icons[tag]}"
    opts[:policy] ||= :tab?
    opts[:policy_arguments] ||= [tag]
    menu_item(tag, opts)
  end
end
