# frozen_string_literal: true
class DecisionPolicy < EdgeablePolicy
  def destroy?
    false
  end

  def feed?
    false
  end
end
