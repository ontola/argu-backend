# frozen_string_literal: true

class NotificationPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      if user && !user.guest?
        scope.where(user_id: user.id)
      else
        scope.where(false)
      end
    end
  end

  def initialize(context, record)
    super(context, record)
    raise.new('must be logged in') unless user
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[user_id title url] if staff?
    attributes
  end

  def read?
    !user.guest?
  end

  def show?
    record.user == user
  end

  def create?
    false
  end

  def update?
    user == record.user
  end
end
