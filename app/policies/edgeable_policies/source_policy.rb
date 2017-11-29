# frozen_string_literal: true

class SourcePolicy < EdgeablePolicy
  def permitted_attributes
    attributes = super
    attributes.concat %i[name iri_base shortname]
    attributes.concat %i[public_grant] if staff?
    attributes
  end

  def permitted_tabs
    %i[general]
  end

  def settings?
    update?
  end
end
