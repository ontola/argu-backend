# frozen_string_literal: true

class ShortnamePolicy < EdgeTreePolicy
  permit_attributes %i[shortname destination]
  permit_attributes %i[unscoped], grant_sets: %i[staff]

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
