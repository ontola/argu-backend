# frozen_string_literal: true

class ContainerNodePolicy < EdgePolicy
  permit_attributes %i[display_name bio locale]

  def create?
    return false unless ContainerNode.descendants.detect { |klass| has_grant?(:create, klass.name) }
    return forbid_wrong_tier unless feature_enabled?(:container_nodes)

    true
  end

  def destroy?
    verdict = super
    return verdict unless verdict

    return forbid_wrong_tier unless feature_enabled?(:container_nodes)

    true
  end

  def has_content_children?
    false
  end

  def list?
    show?
    true
  end

  def show?
    verdict = super
    raise(ActiveRecord::RecordNotFound) unless record.discoverable? || verdict

    verdict
  end
end
