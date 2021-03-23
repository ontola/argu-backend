# frozen_string_literal: true

class NilClassPolicy < RestrictivePolicy
  attr_reader :user, :record

  def initialize(_user, _record)
    raise Pundit::NotAuthorizedError.new('Cannot get policy for nil')
  end

  def permitted_attributes
    []
  end

  def scope
    Pundit.policy_scope!(nil, nil.class)
  end

  class Scope
    def initialize; end

    def resolve
      scope
    end
  end
end
