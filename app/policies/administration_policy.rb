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
    user.profile.has_role? :staff
  end

  def list?
    user.profile.has_role? :staff
  end
end
