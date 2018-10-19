# frozen_string_literal: true

class GuestUserPolicy < UserPolicy
  def follow_items?
    false
  end
end
