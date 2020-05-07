# frozen_string_literal: true

class BannerDismissalPolicy < EdgePolicy
  class Scope < EdgeTreePolicy::Scope; end
  def show?
    true
  end

  def create?
    true
  end
end
