# frozen_string_literal: true

class DirectMessagePolicy < EdgeTreePolicy
  def permitted_attribute_names
    %i[body email_address_id resource_iri subject actor]
  end

  def create?
    edgeable_policy.contact?
  end

  delegate :show, to: :edgeable_policy
end
