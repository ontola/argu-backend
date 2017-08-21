# frozen_string_literal: true
class ProjectPolicy < EdgeablePolicy
  def create?
    false
  end
end
