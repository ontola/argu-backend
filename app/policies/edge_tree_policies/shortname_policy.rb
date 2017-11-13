# frozen_string_literal: true

class ShortnamePolicy < EdgeTreePolicy
  def permitted_attributes
    attributes = super
    attributes.concat %i[shortname owner_id owner_type]
    attributes
  end
  delegate :update?, :show?, to: :edgeable_policy

  def create?
    return if edgeable_record.shortnames_depleted?
    edgeable_policy.update?
  end

  def destroy?
    edgeable_policy.update?
  end

  private

  def edgeable_record
    @edgeable_record ||= record.forum
  end
end
