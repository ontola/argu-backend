# frozen_string_literal: true

module Request
  class TrashRequest < Base
    enhance Trashable, only: %i[Model Serializer]
  end
end