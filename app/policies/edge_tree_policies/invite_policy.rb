# frozen_string_literal: true

class InvitePolicy < EdgeTreePolicy
  permit_attributes %i[addresses send_mail group_id root_id redirect_url message]
  permit_attributes %i[creator], creator: true, new_record: true

  def create?
    edgeable_policy.invite?
  end

  def show?
    edgeable_policy.invite?
  end
end
