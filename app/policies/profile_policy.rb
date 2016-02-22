class ProfilePolicy < RestrictivePolicy
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
      scope.where(is_public: true)
    end
  end

  def permitted_attributes
    attributes = super
    append_default_photo_params(attributes)
    attributes << %i(id name about are_votes_public is_public)
    attributes
  end

  def index
    is_manager? || is_owner? || staff?
  end

  def new?
    Pundit.policy(context, record.profileable_type.constantize).create?
  end

  def show?
    Pundit.policy(context, record.profileable).show?
  end
  deprecate show?: 'Please use the more consise method on profileable instead.'

  def update?
    Pundit.policy(context, record.profileable).update? || super
  end

  def edit?
    update?
  end
end
