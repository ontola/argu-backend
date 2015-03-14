module ForumsHelper
  include DropdownHelper

  def application_form_member_label(value)
    t("forums.application_form.#{value}")
  end

  def forum_title_dropdown_items(resource)
    link_items = []
    current_profile.present? && current_profile.memberships.each do |membership|
      link_items << link_item(membership.forum.display_name, url_for(membership.forum), image: membership.forum.profile_photo.url(:icon))
    end

    divided = false
    if policy(@forum).is_member?
      if active_for_user?(:notifications, current_user)
        divided = true
        if current_profile.following?(@forum)
          link_items << link_item(t('forums.unfollow'), follows_path(forum_id: @forum.web_url), fa: 'times', divider: 'top', data: {method: 'delete', 'skip-pjax' => 'true'})
        else
          link_items << link_item(t('forums.follow'), follows_path(forum_id: @forum.web_url), fa: 'check', divider: 'top', data: {method: 'create', 'skip-pjax' => 'true'})
        end
      end
      link_items << link_item(t('forums.leave'), forum_membership_path(@forum.web_url, current_profile), fa: 'sign-out', divider: (divided ? 'top' : nil),
                              data: {method: :delete, 'skip-pjax' => 'true', confirm: t('forums.leave_confirmation')})
    end
    link_items << link_item(t('forums.discover'), forums_url, fa: 'compass')
    dropdown_options(resource.name, [{items: link_items}], triggerTag: 'h1', fa_after: 'fa-angle-down')
  end

  def manage_button_dropdown_items(resource)
    link_items = []
    link_items << link_item(t('forums.settings.title'), url_for([:settings, resource]), fa: 'gear')
    link_items << link_item(t('forums.statistics.title'), url_for([:statistics, resource]), fa: 'pie-chart') if policy(resource).statistics?
    link_items << link_item(t('forums.settings.managers'), url_for([:settings, resource, tab: :managers]), fa: 'group') if policy(resource).managers?

    dropdown_options(t("#{resource.class_name}.resource_name.management"),
                     [{items: link_items}], fa: 'fa-gear', fa_after: 'fa-angle-down')
  end

  def public_form_member_label(value)
    t("forums.public_form.#{value}")
  end

  def scope_member_label(value)
    t("forums.scope.#{value}")
  end

end
