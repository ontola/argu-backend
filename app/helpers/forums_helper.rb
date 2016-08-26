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
        defaultAction: discover_forums_path,
        dropdownClass: 'navbar-forum-selector',
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
        triggerTag: 'h1'
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
      membership = current_profile
                     .group_memberships
                     .joins(grants: :edge)
                     .where(edges: {owner_id: @forum.id})
                     .first
      items << link_item(t('forums.leave'),
                         group_membership_path(membership),
                         fa: 'sign-out',
                         data: {method: :delete, turbolinks: 'false', confirm: t('forums.leave_confirmation')})
    end
  end

  def manage_button_dropdown_items(resource)
    items = []
    items << link_item(t('forums.settings.title'),
                       url_for([:settings, resource]), fa: 'gear')
    if policy(resource).statistics?
      items << link_item(t('forums.statistics.title'),
                         url_for([:statistics, resource]), fa: 'pie-chart')
    end
    if policy(resource).managers?
      items << link_item(t('forums.settings.grants.title'),
                         url_for([:settings, resource, tab: :grants]), fa: 'group')
    end

    dropdown_options(t("#{resource.class_name}.resource_name.management"),
                     [{items: items}], fa: 'fa-gear')
  end

  def public_form_member_label(value)
    t("forums.public_form.#{value}")
  end

  def scope_member_label(value)
    t("forums.scope.#{value}")
  end

  def shortname_owner_types
    [
      %w(Project Project),
      %w(Question Question),
      %w(Motion Motion),
      %w(Argument Argument),
      %w(Comment Comment)
    ]
  end
end
