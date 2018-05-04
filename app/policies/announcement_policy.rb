# frozen_string_literal: true

class AnnouncementPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      audience = [Announcement.audiences[:everyone]]
      audience <<
        if user.guest?
          Announcement.audiences[:guests]
        else
          Announcement.audiences[:users]
        end
      scope
        .where(audience: audience)
        .published
    end
  end

  def permitted_attribute_names
    attributes = super
    if create?
      attributes.concat %i[title forum cited_profile content cited_name
                           audience cited_function published_at ends_at]
    end
    attributes.append :id if staff?
    attributes
  end

  def create?
    staff?
  end

  def destroy?
    staff?
  end

  def update?
    staff?
  end
end
