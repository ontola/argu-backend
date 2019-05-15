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
end
