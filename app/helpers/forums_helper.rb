# frozen_string_literal: true
module ForumsHelper
  include DropdownHelper

  def application_form_member_label(value)
    t("forums.application_form.#{value}")
  end

  def forum_selector_items(_guest = false)
    sections = []

    sections << forum_membership_section unless current_user.guest?
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
      items: profile_favorite_items
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

    pub_forum_items = public_forum_items(5)

    items.concat(pub_forum_items - profile_favorite_items) if items.length < pub_forum_items.length + 1
    items << link_item(t('forums.show_open'), discover_forums_path, fa: 'compass')
  end

  def forum_title_dropdown_items(resource)
    sections = []

    sections << forum_membership_section unless current_user.guest?
    sections << forum_discover_section
    sections << forum_current_section if current_user.has_favorite?(@forum.edge)

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
    return unless current_user.has_favorite?(@forum.edge)
    items = []
    items << link_item(t('forums.leave'),
                       forum_favorites_path(@forum),
                       fa: 'sign-out',
                       data: {method: :delete, turbolinks: 'false', confirm: t('forums.leave_confirmation')})
  end

  def options_for_forum_visibility
    Forum.visibilities.keys.map { |n| [n, n] }
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
