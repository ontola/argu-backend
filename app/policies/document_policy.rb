# frozen_string_literal: true
class DocumentPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  # #####CRUD######
  def show?
    true
  end
end
