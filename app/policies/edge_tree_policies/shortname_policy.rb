# frozen_string_literal: true

class ShortnamePolicy < EdgeTreePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[shortname destination]
    attributes.concat %i[unscoped] if staff?
    attributes
  end
  delegate :show?, to: :edgeable_policy

  def update?
    return unless valid_owner_type?
    return if record.primary?

    edgeable_policy.update?
  end

  def create?
    return unless valid_owner_type?

    edgeable_policy.update?
  end

  def destroy?
    return if record.primary?

    edgeable_policy.update?
  end

  def show?
    edgeable_policy.update?
  end

  private

  def valid_owner_type?
    record.owner.is_a?(Edge)
  end
end
