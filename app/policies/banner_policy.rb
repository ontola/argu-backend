class BannerPolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

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
      audience = [Banner.audiences[:everyone]]
      if user && user.member_of?(context.forum)
        audience << Banner.audiences[:members]
      elsif user.present?
        audience << Banner.audiences[:users]
      else
        audience << Banner.audiences[:guests]
      end
      scope.where(audience: audience)
    end
  end

  def permitted_attributes
    attributes = super
    attributes << [:title, :forum, :cited_profile, :content,
                   :cited_avatar, :cited_name, :audience,
                   :cited_function, :published_at, :ends_at] if create?
    attributes << [:id] if staff?
    attributes
  end

  def create?
    rule is_manager?, is_owner?, super
  end

  def destroy?
    rule is_manager?, is_owner?, super
  end

  def edit?
    update?
  end

  def new?
    create?
  end

  def update?
    rule is_manager?, is_owner?, super
  end

  private

  def forum_policy
    if record.is_a?(Class) || record.forum.blank?
      Pundit.policy(context, :restrictive)
    else
      super
    end
  end
end
