# frozen_string_literal: true

class BlankSerializer < ActiveModel::Serializer
  def id
    0
  end
end
