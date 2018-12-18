# frozen_string_literal: true

class InvitePolicy < EdgeTreePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[addresses send_mail group_id root_id redirect_url message]
    attributes
  end

  def create?
    edgeable_policy.invite?
  end
end
