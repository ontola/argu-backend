# frozen_string_literal: true

class DirectMessagePolicy < EdgeTreePolicy
  permit_attributes %i[body email_address_id resource_iri subject actor]
  # permit_attributes %i[actor], creator: true, new_record: true

  def create?
    edgeable_policy.contact?
  end

  delegate :show?, to: :edgeable_policy
end
