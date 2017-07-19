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
    attributes.concat %i(title forum cited_profile content cited_name audience
                         cited_function published_at ends_at) if create?
    append_default_photo_params(attributes)
    attributes.append :id if staff?
    attributes
  end

  private

  def edge
    record.forum.edge
  end

  def create_roles
    [is_super_admin?, super]
  end

  def destroy_roles
    [is_super_admin?, super]
  end

  def update_roles
    [is_super_admin?, super]
  end
end
