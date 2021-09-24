# frozen_string_literal: true

class NilClassPolicy < RestrictivePolicy
  attr_reader :user, :record

  def initialize(_user, _record) # rubocop:disable Lint/MissingSuper
    raise ActiveRecord::RecordNotFound.new('No resource to authorize')
  end

  def permitted_attributes
    []
  end

  def scope
    Pundit.policy_scope!(nil, nil.class)
  end

  class Scope
    def initialize(_context, _scope); end

    def resolve
      []
    end
  end
end
