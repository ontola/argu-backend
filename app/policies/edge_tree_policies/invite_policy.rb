# frozen_string_literal: true

class InvitePolicy < EdgeTreePolicy
  permit_attributes %i[group_id root_id redirect_url]
  permit_attributes %i[addresses send_mail message creator], has_values: {token_type: :email_type}
  permit_attributes %i[bearer_token_collection max_usages expires_at], has_values: {token_type: :bearer_type}
  permit_attributes %i[token_type]

  def create?
    edgeable_policy.invite?
  end

  def show?
    edgeable_policy.invite?
  end
end
