# frozen_string_literal: true

class VirtualResource
  include ActiveModel::Serialization
  include ActiveModel::Model

  include LinkedRails::Model
  include ApplicationModel

  class_attribute :defined_enums, default: {}.with_indifferent_access

  collection_options(
    association_base: -> { [] }
  )

  def anonymous_iri?
    true
  end

  def new_record?
    true
  end

  def persisted?
    false
  end

  def serializer_class
    self.class.serializer_class
  end

  class << self
    def enum(**opts)
      defined_enums.merge!(opts)
    end

    def serializer_class
      "#{class_name.singularize}_serializer".classify.safe_constantize
    end
  end
end
