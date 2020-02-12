# frozen_string_literal: true

class CreateGroup < CreateService
  def initialize(parent, attributes: {}, options: {})
    raise 'The parent of a Group must be the Edge of a Page' unless parent.owner_type == 'Page'

    @resource = Group.new(page: parent)
    if attributes[:grants_attributes]&.values&.first.try(:[], 'grant_set_id') == '-1'
      attributes = attributes.except(:grants_attributes)
    end
    super
  end

  private

  def object_attributes=(obj)
    obj.group = resource
  end
end
