module ForumsHelper
  include DropdownHelper

  def application_form_member_label(value)
    t("forums.application_form.#{value}")
  end


  def forum_selector_items(guest= false)
    sections = []

    sections << forum_membership_section if current_user.present?
    sections << forum_discover_section

    {
        title: t('forums.plural'),
        fa: 'fa-group',
        sections: sections,
        triggerClass: 'navbar-item navbar-forums'
    }
  end

  def forum_membership_section
    {
        title: t('forums.my'),
        items: profile_membership_items
    }
  end

  def forum_discover_section
    {
        title: t('forums.discover'),
        items: forum_discover_items
    }
  end

  def forum_discover_items
    items = []

    _public_forum_items = public_forum_items(5)

    items.concat (_public_forum_items - profile_membership_items) if items.length < _public_forum_items.length + 1
    items << link_item(t('forums.show_open'), discover_forums_path, fa: 'compass')
  end

  def forum_title_dropdown_items(resource)

    sections = []

    sections << forum_membership_section if current_user.present?
    sections << forum_discover_section
    sections << forum_current_section if current_user.present? && policy(@forum).is_member?

    {
        title: resource.name,
        fa_after: 'fa-angle-down',
        sections: sections,
        triggerTag: 'h1',
    }
  end

  def forum_current_section
    {
        title: t('forums.current'),
        items: forum_membership_controls_items
    }
  end

  def forum_membership_controls_items
    items = []

    if policy(@forum).is_member?
      if active_for_user?(:notifications, current_user)
        divided = true
        if current_profile.following?(@forum)
          items << link_item(t('forums.unfollow'), follows_path(forum_id: @forum.url), fa: 'times', data: {method: 'delete', 'skip-pjax' => 'true'})
        else
          items << link_item(t('forums.follow'), follows_path(forum_id: @forum.url), fa: 'check', rel: :nofollow, data: {method: 'post', 'skip-pjax' => 'true'})
        end
      end
      items << link_item(t('forums.leave'), forum_membership_path(@forum.url, current_profile), fa: 'sign-out',
                         data: {method: :delete, 'skip-pjax' => 'true', confirm: t('forums.leave_confirmation')})
    end
  end

  def manage_button_dropdown_items(resource)
    items = []
    items << link_item(t('forums.settings.title'), url_for([:settings, resource]), fa: 'gear')
    items << link_item(t('forums.statistics.title'), url_for([:statistics, resource]), fa: 'pie-chart') if policy(resource).statistics?
    items << link_item(t('forums.settings.managers.title'), url_for([:settings, resource, tab: :managers]), fa: 'group') if policy(resource).managers?

    dropdown_options(t("#{resource.class_name}.resource_name.management"),
                     [{items: items}], fa: 'fa-gear')
  end

  def public_form_member_label(value)
    t("forums.public_form.#{value}")
  end

  def scope_member_label(value)
    t("forums.scope.#{value}")
  end

end
