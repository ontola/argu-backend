# frozen_string_literal: true

module Request
  class ConfirmedDestroyRequest < Request::Base
    enhance ConfirmedDestroyable, only: %i[Model Serializer]
  end
end
