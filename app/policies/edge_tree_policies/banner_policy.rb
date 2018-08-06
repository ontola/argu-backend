# frozen_string_literal: true

class BannerPolicy < EdgeTreePolicy
  include ProfilePhotoable::Policy

  class Scope < Scope
    def resolve
      audience = [Banner.audiences[:everyone]]
      audience <<
        if user.guest?
          Banner.audiences[:guests]
        else
          Banner.audiences[:users]
        end
      scope.where(audience: audience)
    end
  end

  def permitted_attribute_names
    attributes = super
    if create?
      attributes.concat %i[title forum cited_profile content cited_name audience
                           cited_function published_at ends_at]
    end
    attributes.append :id if staff?
    attributes
  end

  delegate :update?, :show?, to: :edgeable_policy

  def create?
    edgeable_policy.update?
  end

  def destroy?
    edgeable_policy.update?
  end
end
