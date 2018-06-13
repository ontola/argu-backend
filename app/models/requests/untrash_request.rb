# frozen_string_literal: true

class UntrashRequest < Request
  enhance Trashable, only: %i[Model Serializer]
end
