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

  def permitted_attributes(password= false)
    attributes = super()
    attributes << [:email, :password, :password_confirmation, {profile_attributes: [:name, :profile_photo]}] if create?
    attributes << [{shortname_attributes: [:shortname]}] if new_record?
    attributes << [:follows_email, :follows_mobile, :memberships_email, :memberships_mobile, :created_email,
                   :created_mobile, :has_analytics, :time_zone, :language, :country, :birthday] if update?
    attributes << [:current_password, :password, :password_confirmation, :email] if password
    attributes << [profile_attributes: ProfilePolicy.new(context,record.profile).permitted_attributes]
    attributes
  end

  def index?
    staff?
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
    record.id == user.id
  end

  def destroy?
    record.id == user.id
  end
end
