class NilClassPolicy < RestrictivePolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'An error occurred'
  end

  def permitted_attributes
    []
  end

  def scope
    Pundit.policy_scope!(nil, nil.class)
  end

  class Scope
    def initialize
    end

    def resolve
      scope
    end
  end
end
