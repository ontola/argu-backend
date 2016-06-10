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
    attributes.append(home_placement_attributes: %i(postal_code country_code id))
    attributes.append(shortname_attributes: %i(shortname)) if new_record?
    attributes.concat %i(first_name middle_name last_name)
    attributes.concat %i(reactions_email news_email decisions_email memberships_email created_email
                         has_analytics has_analytics time_zone language birthday) if update?
    attributes.concat %i(current_password password password_confirmation email) if password
    attributes.append(profile_attributes: ProfilePolicy.new(context,record.profile).permitted_attributes)
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(general profile notifications privacy advanced)
    tabs
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

  def settings?
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

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'general'
    assert! permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end
end
