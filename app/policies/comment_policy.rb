class CommentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def report?
    true
  end
end
