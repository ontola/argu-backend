module SettingsHelper
  def tab_icons
    {
      general: 'gear',
      advanced: 'gears',
      grants: 'suitcase',
      groups: 'group',
      projects: 'rocket',
      privacy: 'lock',
      shortnames: 'external-link',
      banners: 'sticky-note',
      setting: 'sliders',
      announcements: 'bullhorn',
      profile: 'user',
      notifications: 'bell',
      authentication: 'shield'
    }
  end

  def group_redirect_url(group)
    edit_group_path(group)
  end

  def visibility_icon_for(item)
    case item.visibility
    when 'closed'
      'close'
    when 'hidden'
      'lock'
    when 'open'
      'globe'
    when 'discussion'
      'commenting'
    end
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
    for_resource = if resource.is_a?(Symbol)
                     resource.downcase
                   else
                     resource.is_a?(User) ? nil : resource
                   end
    url_for([:settings, for_resource, tab: tab])
  end
end
