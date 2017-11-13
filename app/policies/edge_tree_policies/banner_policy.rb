# frozen_string_literal: true

class BannerPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      audience = [Banner.audiences[:everyone]]
      audience <<
        if user.guest?
          Banner.audiences[:guests]
        elsif user.member_of?(scope.build.forum)
          Banner.audiences[:members]
        else
          Banner.audiences[:users]
        end
      scope.where(audience: audience)
    end
  end

  def permitted_attributes
    attributes = super
    if create?
      attributes.concat %i[title forum cited_profile content cited_name audience
                           cited_function published_at ends_at]
    end
    append_default_photo_params(attributes)
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

  private

  def edgeable_record
    @edgeable_record ||= record.forum
  end
end
