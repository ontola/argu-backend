# frozen_string_literal: true

class DirectMessagePolicy < EdgeTreePolicy
  def permitted_attribute_names
    %i[body email resource_iri subject actor]
  end

  def create?
    edgeable_policy.contact?
  end
end
