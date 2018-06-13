# frozen_string_literal: true

class TrashRequest < Request
  enhance Trashable, only: %i[Model Serializer]
end
