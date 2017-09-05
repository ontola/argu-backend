# frozen_string_literal: true

# @private
class AdministrationPolicy < Struct.new(:context, :administration)
  class Scope
    def resolve
      scope
    end
  end

  delegate :user, to: :context
  delegate :actor, to: :context

  def show?
    user.is_staff?
  end

  def list?
    user.is_staff?
  end
end
