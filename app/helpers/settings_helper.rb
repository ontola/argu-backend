# frozen_string_literal: true

module SettingsHelper
  def tab_icons
    {
      general: 'cog',
      advanced: 'cogs',
      grants: 'suitcase',
      groups: 'users',
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
      invite: 'user-plus'
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
end
