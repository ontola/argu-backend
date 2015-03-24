class UserPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :user, :scope, :session

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

  def permitted_attributes
    attributes = super
    attributes << [:email, :password, :password_confirmation, {profile_attributes: [:name, :profile_photo]}] if create?
    attributes << [{shortname_attributes: [:shortname]}] if new_record?
    attributes
  end

  def index?
    staff?
  end

  def edit?
    record.id == user.id
  end
end
