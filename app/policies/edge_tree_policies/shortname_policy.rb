# frozen_string_literal: true

class ShortnamePolicy < EdgeTreePolicy
  SAFE_OWNER_TYPES = %w[Question Motion Argument Comment].freeze

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[shortname]
    attributes
  end
  delegate :update?, :show?, to: :edgeable_policy

  def create?
    return if edgeable_record.shortnames_depleted?
    return unless valid_owner_type?
    edgeable_policy.update?
  end

  def destroy?
    edgeable_policy.update?
  end

  private

  def edgeable_record
    @edgeable_record ||= record.forum
  end

  def valid_owner_type?
    record.owner.nil? || SAFE_OWNER_TYPES.include?(record.owner.owner_type)
  end
end
