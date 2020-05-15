# frozen_string_literal: true

class VirtualResource
  include ActiveModel::Serialization
  include ActiveModel::Model

  include LinkedRails::Model
  include ApplicationModel

  def new_record?
    true
  end

  def persisted?
    false
  end

  def self.serializer_class
    "#{class_name.singularize}_serializer".classify.constantize
  end

  def serializer_class
    self.class.serializer_class
  end
end
