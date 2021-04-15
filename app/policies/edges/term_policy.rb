# frozen_string_literal: true

class TermPolicy < EdgePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[display_name description]

  delegate :show?, to: :parent_policy
end
