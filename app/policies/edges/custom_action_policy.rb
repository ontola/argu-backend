# frozen_string_literal: true

class CustomActionPolicy < EdgePolicy
  permit_attributes %i[raw_label raw_description raw_submit_label href]

  def create?
    verdict = super

    return verdict unless verdict
    return forbid_wrong_tier unless feature_enabled?(:widgets)

    true
  end

  def update?
    verdict = super

    return verdict unless verdict
    return forbid_wrong_tier unless feature_enabled?(:widgets)

    true
  end
end
