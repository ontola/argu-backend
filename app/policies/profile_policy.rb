# frozen_string_literal: true
class ProfilePolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(id name about are_votes_public is_public)
    append_default_photo_params(attributes)
    attributes
  end

  def show?
    Pundit.policy(context, record.profileable).show?
  end
  deprecate show?: 'Please use the more consise method on profileable instead.'

  def update?
    Pundit.policy(context, record.profileable).update? || super
  end
end
