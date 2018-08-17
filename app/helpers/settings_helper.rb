# frozen_string_literal: true

module SettingsHelper
  def tab_icons
    {
      general: 'gear',
      advanced: 'gears',
      delete: 'trash',
      grants: 'suitcase',
      groups: 'group',
      forums: 'comments',
      privacy: 'lock',
      shortnames: 'external-link',
      banners: 'sticky-note',
      setting: 'sliders',
      sources: 'database',
      announcements: 'bullhorn',
      profile: 'user',
      notifications: 'bell',
      authentication: 'shield',
      members: 'users',
      invite: 'user-plus',
      bearer_invite: 'link',
      email_invite: 'send'
    }
  end

  def group_redirect_url(group)
    settings_iri_path(group, tab: :members)
  end

  def render_settings_items_for(resource, active)
    content_tag :ul, class: 'tabs tabs--vertical' do
      policy(resource).permitted_tabs.each do |tab|
        concat render partial: 'application/settings_item',
                      locals: {
                        resource: resource,
                        tab: tab,
                        active: active
                      }
      end
    end
  end

  def setting_item(tag, opts)
    opts[:image] ||= "fa-#{tab_icons[tag]}"
    opts[:policy] ||= :tab?
    opts[:policy_arguments] ||= [tag]
    menu_item(tag, opts)
  end
end
