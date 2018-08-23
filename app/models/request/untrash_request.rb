# frozen_string_literal: true

module Request
  class UntrashRequest < Base
    enhance Trashable, only: %i[Model Serializer]
  end
end
