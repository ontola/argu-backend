
# frozen_string_literal: true
class CreateGroup < EdgeableCreateService
  def initialize(parent, attributes: {}, options: {})
    raise 'The parent of a Group must be the Edge of a Page' unless parent.owner_type == 'Page'
    if attributes[:grants_attributes]&.values&.first.try(:[], 'role') == 'empty'
      attributes = attributes.except(:grants_attributes)
    end
    super
  end

  private

  def object_attributes=(obj)
    obj.group = resource
  end

  def parent_columns
    %i(page_id)
  end
end
