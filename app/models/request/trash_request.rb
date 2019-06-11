# frozen_string_literal: true

module Request
  class TrashRequest < Request::Base
    enhance Trashable, only: %i[Model Serializer]
  end
end
