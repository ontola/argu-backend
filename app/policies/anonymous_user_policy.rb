# frozen_string_literal: true

class AnonymousUserPolicy < UserPolicy
  def show?
    true
  end
end
