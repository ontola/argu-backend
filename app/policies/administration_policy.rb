# frozen_string_literal: true

# @private
class AdministrationPolicy < Struct.new(:context, :administration) # rubocop:disable Style/StructInheritance
  class Scope
    def resolve
      scope
    end
  end

  delegate :user, to: :context
  delegate :profile, to: :context

  def show?
    user.is_staff?
  end
end
