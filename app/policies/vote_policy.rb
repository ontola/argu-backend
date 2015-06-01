class VotePolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @memberships = @profile.memberships if @profile
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      if staff?
        scope
      else
        scope
        profiles = Profile.arel_table
        scope.joins(:voter).where(profiles[:are_votes_public].eq(true))
      end
    end

  end

  def create?
    rule is_open?, is_member?, super
  end

  def new?
    rule is_open?, create?
  end

end
