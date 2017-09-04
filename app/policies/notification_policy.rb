# frozen_string_literal: true

class NotificationPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      if user
        scope.where(user_id: user.id)
      else
        scope.where(false)
      end
    end
  end

  def initialize(context, record)
    super(context, record)
    raise .new('must be logged in') unless user
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(user_id title url) if staff?
    attributes
  end

  def read?
    !user.guest?
  end

  def create?
    staff?
  end

  def update?
    user == record.user
  end
end
