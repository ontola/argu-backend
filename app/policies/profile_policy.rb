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
    attributes.concat %i[id]
    if record.profileable.is_a?(Page)
      attributes.concat %i[name]
    else
      attributes.concat %i[first_name last_name hide_last_name]
    end
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
    record.profileable.show_feed? || Pundit.policy(context, record.profileable).update?
  end

  def setup?
    update?
  end
end
