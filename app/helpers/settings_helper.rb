# frozen_string_literal: true

module SettingsHelper
  def tab_icons
    {
      general: 'gear',
      advanced: 'gears',
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
      invite: 'user-plus'
    }
  end

  def group_redirect_url(group)
    settings_group_path(group, tab: :members)
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

  def settings_url_for(resource, tab)
    return portal_settings_path if resource == :Portal
    for_resource = case resource
                   when Symbol
                     resource.downcase
                   when User
                     nil
                   when Source
                     [resource.page, resource]
                   else
                     resource
                   end
    url_for([:settings, for_resource, tab: tab].flatten)
  end
end
