# frozen_string_literal: true

class SourcePolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i[name iri_base shortname]
    attributes.concat %i[public_grant] if staff?
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[general] if is_super_admin? || staff?
    tabs
  end

  # #####Actions######
  def settings?
    update?
  end

  def show?
    rule is_member?, is_manager?, super
  end

  def update?
    rule is_super_admin?, super
  end
end
