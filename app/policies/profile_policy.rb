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
    if record.profileable.present?
      attributes << [:id, :name, :about, :profile_photo, :remove_profile_photo, :cover_photo,
                     :remove_cover_photo, :are_votes_public, :is_public] if update?
    else
      attributes << [:id, :name, :about, :profile_photo, :cover_photo, :are_votes_public, :is_public] if new?
    end
    attributes
  end

  def index?
    is_manager_somewhere? || is_owner_somewhere? || staff?
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

  private

  def is_manager_somewhere?
    user && (user.profile.managerships.present? || user.profile.page_managerships.present?)
  end

  def is_owner_somewhere?
    user && user.profile.pages.present?
  end
end
