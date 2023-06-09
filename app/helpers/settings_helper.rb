# frozen_string_literal: true

module SettingsHelper
  def tab_icons # rubocop:disable Metrics/MethodLength
    {
      general: 'gear',
      advanced: 'gears',
      drafts: 'file',
      container_nodes: 'cubes',
      custom_menu_items: 'bars',
      delete: 'trash',
      edit: 'pencil-square-o',
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
      email_invite: 'send',
      vocabularies: 'tags',
      settings: 'gear',
      submissions: 'list-ul',
      submission: 'pencil',
      participate: 'pencil'
    }
  end

  def setting_item(tag, opts)
    menu_item(tag, setting_item_opts(tag, opts))
  end

  def setting_item_opts(tag, opts)
    opts[:description] ||= I18n.t("menus.descriptions.#{tag}", default: nil)
    opts[:image] ||= "fa-#{tab_icons[tag]}"
    opts[:policy] ||= :tab?
    opts[:policy_arguments] ||= [tag]
    opts
  end
end
