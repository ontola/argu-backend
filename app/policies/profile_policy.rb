# frozen_string_literal: true

class ProfilePolicy < RestrictivePolicy
  include ProfilePhotoable::Policy

  class Scope < Scope
    def resolve
      scope
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[id name about are_votes_public is_public]
    attributes
  end

  def show?
    Pundit.policy(context, record.profileable).show?
  end
  deprecate show?: 'Please use the more consise method on profileable instead.'

  def update?
    Pundit.policy(context, record.profileable).update? || super
  end

  def feed?
    record.are_votes_public? || Pundit.policy(context, record.profileable).update?
  end
end
