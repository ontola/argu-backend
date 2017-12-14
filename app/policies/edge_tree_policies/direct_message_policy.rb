# frozen_string_literal: true

class DirectMessagePolicy < EdgeTreePolicy
  def permitted_attributes
    %i[body email resource_iri subject]
  end

  def create?
    edgeable_policy.contact?
  end

  private

  def edgeable_record
    record.resource
  end
end
