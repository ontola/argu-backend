# frozen_string_literal: true

class ShortnamePolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      scope
        .joins(:owner)
        .where(primary: false)
        .where('COALESCE(shortnames.root_id, edges.root_id) = ?', ActsAsTenant.current_tenant.uuid)
    end
  end

  permit_attributes %i[shortname destination]

  delegate :show?, to: :edgeable_policy

  def update?
    return forbid_with_message(I18n.t('actions.shortnames.create.errors.invalid_type')) unless valid_owner_type?
    return forbid_with_message(I18n.t('actions.shortnames.update.errors.primary')) if record.primary?

    edgeable_policy.update?
  end

  def create?
    return forbid_with_message(I18n.t('actions.shortnames.create.errors.invalid_type')) unless valid_owner_type?
    return false unless edgeable_policy.update?
    return forbid_wrong_tier unless feature_enabled?(:shortnames)

    true
  end

  def destroy?
    return forbid_with_message(I18n.t('actions.shortnames.destroy.errors.primary')) if record.primary?

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
