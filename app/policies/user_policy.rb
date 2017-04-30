# frozen_string_literal: true
class UserPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def permitted_attributes(password = false)
    attrs = super()
    if create?
      attrs.concat %i(password password_confirmation primary_email)
      attrs.append(profile_attributes: %i(name profile_photo))
    end
    attrs.append(home_placement_attributes: %i(postal_code country_code id))
    attrs.append(emails_attributes: %i(email _destroy id))
    attrs.append(shortname_attributes: %i(shortname)) if new_record?
    attrs.concat %i(first_name middle_name last_name)
    if update?
      attrs.concat(
        %i(reactions_email news_email decisions_email memberships_email
           created_email has_analytics has_analytics time_zone language
           birthday)
      )
    end
    attrs.concat %i(current_password password password_confirmation) if password
    attrs.append(profile_attributes: ProfilePolicy
                                       .new(context, record.profile)
                                       .permitted_attributes)
    attrs
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(general profile authentication notifications privacy advanced)
  end

  def show?
    (record.profile.is_public? || !user.guest?) && record.finished_intro? ||
      super
  end

  def create?
    true
  end

  def feed?
    record.profile.are_votes_public? || Pundit.policy(context, record).update?
  end

  def max_allowed_pages
    if staff?
      Float::INFINITY
    elsif user
      1
    else
      0
    end
  end

  def max_pages_reached?
    user.profile.pages.length >= max_allowed_pages
  end

  def settings?
    current_user?
  end

  def update?
    current_user? || super
  end

  def setup?
    current_user? && user.url.blank?
  end

  def destroy?
    return if record.profile.grants.super_admin.count.positive?
    current_user?
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'general'
    assert! permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end

  def current_user?
    record.id == user.id
  end
end
