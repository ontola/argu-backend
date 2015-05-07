module SettingsHelper

  def tab_icon_for(tab)
    case tab
      when :general, :advanced
        'gear'
      when :managers, :groups
        'group'
      when :privacy
        'shield'
    end
  end

  def render_settings_items_for(resource, active)
    content_tag :ul, class: 'tabs tabs--vertical' do
      policy(resource).permitted_tabs.each do |tab|
        concat render partial: 'application/settings_item', locals: {
                                                       resource: resource,
                                                       tab: tab,
                                                       active: active
                                                   }
      end
    end
  end
end
