# frozen_string_literal: true

class VirtualResource
  extend ActiveRecord::Enum
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeMethods
  include ApplicationModel
  include Enhanceable

  alias read_attribute_for_serialization send
end
