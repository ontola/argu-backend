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

  def permitted_attributes
    attributes = super
    attributes.concat %i(title forum cited_profile content cited_name
                         audience cited_function published_at ends_at) if create?
    attributes.append :id if staff?
    attributes
  end

  private

  def create_roles
    [staff?]
  end

  def destroy_roles
    [staff?]
  end

  def update_roles
    [staff?]
  end
end
