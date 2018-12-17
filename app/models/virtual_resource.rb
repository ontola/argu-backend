# frozen_string_literal: true

class VirtualResource
  include ActiveModel::Serialization
  include ActiveModel::Model

  include RailsLD::Model
  include ApplicationModel
  include Enhanceable

  alias read_attribute_for_serialization send

  def new_record?
    true
  end

  def persisted?
    false
  end
end
