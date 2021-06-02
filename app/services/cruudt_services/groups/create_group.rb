# frozen_string_literal: true

class CreateGroup < CreateService
  def initialize(parent, attributes: {}, options: {})
    raise 'The parent of a Group must be a Page' unless parent.is_a?(Page)

    @resource = parent.build_child(Group, user_context: options[:user_context])
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
