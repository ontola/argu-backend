class AnnouncementPolicy < RestrictivePolicy
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
      audience = [Announcement.audiences[:everyone]]
      audience <<
        if user && user.member_of?(context.forum)
          Announcement.audiences[:members]
        elsif user.present?
          Announcement.audiences[:users]
        else
          Announcement.audiences[:guests]
        end
      scope
        .where(audience: audience)
        .published
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
    staff?
  end

  def destroy?
    staff?
  end

  def edit?
    update?
  end

  def new?
    create?
  end

  def update?
    staff?
  end
end
