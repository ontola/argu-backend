# frozen_string_literal: true

class NoRootPolicy < RestrictivePolicy
  def has_expired_ancestors?
    false
  end
end
