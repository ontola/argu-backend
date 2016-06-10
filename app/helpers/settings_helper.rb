module SettingsHelper
  def tab_icon_for(tab)
    case tab
    when :general, :advanced
      'gear'
    when :managers
      'suitcase'
    when :groups
      'group'
    when :projects
      'rocket'
    when :privacy
      'shield'
    when :shortnames
      'external-link'
    when :banners
      'sticky-note'
    when :setting
      'sliders'
    when :announcements
      'bullhorn'
    when :profile
      'user'
    when :notifications
      'bell'
    end
  end

  def group_redirect_url(group)
    tab = group.grants.first&.manager? ? :managers : :groups
    if group.grants.first&.edge&.owner_type == 'Forum'
      settings_forum_path(group.grants.first.edge.owner, tab: tab)
    else
      settings_page_path(group.page.url, tab: tab)
    end
  end

  def group_visibility_icon_for(group)
    case group.visibility
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
