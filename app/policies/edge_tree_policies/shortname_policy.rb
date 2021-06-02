# frozen_string_literal: true

class ShortnamePolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      scope
        .join_edges
        .where(primary: false)
        .where('COALESCE(shortnames.root_id, edges.root_id) = ?', ActsAsTenant.current_tenant.uuid)
    end
  end

  permit_attributes %i[shortname destination]

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
