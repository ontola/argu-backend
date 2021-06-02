# frozen_string_literal: true

class ContainerNodePolicy < EdgePolicy
  permit_attributes %i[display_name bio locale]

  def create?
    ContainerNode.descendants.detect { |klass| has_grant?(:create, klass.name) }
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
