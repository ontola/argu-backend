# frozen_string_literal: true

class NilClassPolicy < RestrictivePolicy
  attr_reader :user, :record

  def initialize(_user, _record)
    raise Pundit::NotAuthorized.new('An error occurred')
  end

  def permitted_attribute_names
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
