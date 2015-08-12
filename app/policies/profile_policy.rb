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
      raise Pundit::NotAuthorizedError, 'must be logged in' unless user
      scope.where(is_public: true)
    end
  end

  def permitted_attributes
    attributes = super
    if record.profileable.present?
      attributes << [:id, :name, :about, :profile_photo, :cover_photo, :are_votes_public, :is_public] if update?
    else
      attributes << [:id, :name, :about, :profile_photo, :cover_photo, :are_votes_public, :is_public] if new?
    end
    attributes
  end

  def index
    is_owner? || staff?
  end

  def new?
    Pundit.policy(context, record.profileable_type.constantize).create?
  end

  def show?
    if record.profileable.class == Page
      record.is_public?
    else
      (record.is_public? || user.present?) && record.profileable.finished_intro? || super
    end
  end

  def update?
    Pundit.policy(context, record.profileable).update? || super
  end

  def edit?
    update?
  end
end
