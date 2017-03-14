# frozen_string_literal: true
class UserPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context

    def resolve
      scope
    end
  end

  def permitted_attributes(password = false)
    attributes = super()
    if create?
      attributes.concat %i(password password_confirmation primary_email)
      attributes.append(profile_attributes: %i(name profile_photo))
    end
    attributes.append(home_placement_attributes: %i(postal_code country_code id))
    attributes.append(emails_attributes: %i(email _destroy id))
    attributes.append(shortname_attributes: %i(shortname)) if new_record?
    attributes.concat %i(first_name middle_name last_name)
    attributes.concat %i(reactions_email news_email decisions_email memberships_email created_email
                         has_analytics has_analytics time_zone language birthday) if update?
    attributes.concat %i(current_password password password_confirmation) if password
    attributes.append(profile_attributes: ProfilePolicy.new(context, record.profile).permitted_attributes)
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(general profile authentication notifications privacy advanced)
  end

  def show?
    (record.profile.is_public? || !user.guest?) && record.finished_intro? || super
  end

  def index_votes?
    Pundit.policy(context, record.profile).index_votes?
  end

  def create?
    true
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
    record.id == user.id
  end

  def update?
    (record.id == user.id) || super
  end

  def setup?
    record.id == user.id && user.url.blank?
  end

  def destroy?
    return if record.profile.grants.super_admin.count.positive?
    record.id == user.id
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'general'
    assert! permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end
end
