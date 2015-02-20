module ForumsHelper
  def application_form_member_label(value)
    t("forums.application_form.#{value}")
  end

  def forum_title_dropdown_items(resource)
    link_items = []
    current_profile.present? && current_profile.memberships.each do |membership|
      link_items << link_item(membership.forum.display_name, url_for(membership.forum), image: membership.forum.profile_photo.url(:icon))
    end
    link_items << link_item(t('forums.leave'), forum_membership_path(@forum.web_url, current_profile), fa: 'sign-out', divider: 'top', method: :delete, data: {confirm: t('forums.leave_confirmation')}) if policy(@forum).is_member?
    link_items << link_item(t('forums.discover'), forums_url, fa: 'compass') if policy(@forum).is_member?
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
