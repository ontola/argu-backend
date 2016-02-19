class BannerDismissalPolicy < RestrictivePolicy
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
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes << [:title, :forum, :cited_profile, :content,
                   :cited_avatar, :cited_name,
                   :cited_function, :published_at] if create?
    attributes << [:id] if staff?
    attributes
  end

  def create?
    case record.banner.audience.to_sym
      when :guests then !user
      when :users then user && !user.member_of?(@forum)
      when :members then user && user.member_of?(@forum)
      when :everyone then true
    end
  end

  private

  def forum_policy
    if record.is_a?(Class) || record.banner.try(:forum).blank?
      Pundit.policy(context, :restrictive)
    else
      super
    end
  end
end
