class GroupPolicy < RestrictivePolicy
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
      # Don't show closed, unless the user has a membership
      scope.where('visibility IN (?) OR groups.id IN (?)',
                  [Group.visibilities[:open], Group.visibilities[:discussion]],
                  user && user.profile.group_memberships.pluck(:group_id))
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(name name_singular icon visibility max_responses_per_member) if create?
    attributes.append :id if staff?
    attributes
  end

  def create?(forum = nil)
    if forum.present?
      record.present? || raise(SecurityError)
      record = Group.new(forum: forum)
    end
    rule is_manager?, super()
  end

  def destroy?
    rule is_owner?, super
  end

  def edit?
    update?
  end

  def new?
    create?
  end

  def update?
    rule is_manager?, super
  end

  def remove_member?(member)
    rule is_manager?
  end
end
