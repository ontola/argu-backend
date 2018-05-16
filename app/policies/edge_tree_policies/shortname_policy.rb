# frozen_string_literal: true

class ShortnamePolicy < EdgeTreePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[shortname]
    attributes
  end
  delegate :show?, to: :edgeable_policy

  def update?
    return unless valid_owner_type?
    return if record.primary?
    return staff? if record.root_id.blank?
    edgeable_policy.update?
  end

  def create?
    update?
  end

  def destroy?
    return if record.primary?
    edgeable_policy.update?
  end

  def show?
    false
  end

  private

  def edgeable_record
    @edgeable_record ||= record.owner.is_a?(Edge) ? record.owner.parent_model(:page) : record.owner
  end

  def valid_owner_type?
    record.owner.is_a?(Edge)
  end
end
