# frozen_string_literal: true

class ProfilePolicy < RestrictivePolicy
  include ProfilePhotoable::Policy

  class Scope < Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[display_name]

  delegate :show?, to: :profileable_policy
  deprecate show?: 'Please use the more consise method on profileable instead.'

  def update?
    profileable_policy.update? || super
  end

  private

  def profileable_policy
    @profileable_policy ||= Pundit.policy(context, record.profileable)
  end
end
