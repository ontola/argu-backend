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
    delegate :session, to: :context

    def resolve
      scope
    end
  end

  def permitted_attributes(password = false)
    attributes = super()
    if create?
      attributes.concat %i(email password password_confirmation)
      attributes.append(profile_attributes: %i(name profile_photo))
    end
    attributes.append(shortname_attributes: %i(shortname)) if new_record?
    attributes.concat %i(reactions_email news_email reactions_mobile memberships_email memberships_mobile created_email
                         created_mobile has_analytics time_zone language postal_code country_code birthday) if update?
    attributes.concat %i(current_password password password_confirmation email) if password
    attributes.append(profile_attributes: ProfilePolicy.new(context, record.profile).permitted_attributes)
    attributes
  end

  def index?
    staff?
  end

  def show?
    (record.profile.is_public? || user.present?) && record.finished_intro? || super
  end

  def create?
    platform_open? || within_user_cap? || has_access_to_record? || super
  end

  def edit?
    record.id == user.id
  end

  def update?
    (user && record.id == user.id) || super
  end

  def setup?
    record.id == user.id && user.url.blank?
  end

  def destroy?
    record.id == user.id
  end
end
