# frozen_string_literal: true

class AccessTokenPolicy < RestrictivePolicy
  permit_attributes %i[email password redirect_url]

  def create?
    true
  end
end
