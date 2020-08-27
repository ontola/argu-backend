# frozen_string_literal: true

class SessionPolicy < RestrictivePolicy
  permit_attributes %i[email redirect_url]

  def create?
    true
  end
end
