# frozen_string_literal: true

require 'requests/request'

class ConfirmedDestroyRequest < Request
  enhance ConfirmedDestroyable, only: %i[Model Serializer]
end
