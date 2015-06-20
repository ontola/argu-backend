module ForumsHelper
  include DropdownHelper

  def application_form_member_label(value)
    t("forums.application_form.#{value}")
  end

  def forum_title_dropdown_items(resource)
    items = []

    items.concat current_profile.present? ? profile_membership_items : public_forum_items

    divided = false
    if policy(@forum).is_member?
      if active_for_user?(:notifications, current_user)
        divided = true
        if current_profile.following?(@forum)
          items << link_item(t('forums.unfollow'), follows_path(forum_id: @forum.url), fa: 'times', divider: 'top', data: {method: 'delete', 'skip-pjax' => 'true'})
        else
          items << link_item(t('forums.follow'), follows_path(forum_id: @forum.url), fa: 'check', divider: 'top', rel: :nofollow, data: {method: 'post', 'skip-pjax' => 'true'})
        end
      end
      items << link_item(t('forums.leave'), forum_membership_path(@forum.url, current_profile), fa: 'sign-out', divider: (divided ? 'top' : nil),
                              data: {method: :delete, 'skip-pjax' => 'true', confirm: t('forums.leave_confirmation')})
    end

    # TODO: Show most popular 3 forums if user has fewer than 2 memberships.

    items << link_item(t('forums.discover'), discover_forums_url, fa: 'compass', divider: 'top')
    dropdown_options(resource.name, [{items: items}], triggerTag: 'h1', fa_after: 'fa-angle-down')
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
