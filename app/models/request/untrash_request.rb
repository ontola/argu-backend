# frozen_string_literal: true

module Request
  class UntrashRequest < Request::Base
    enhance Trashable, only: %i[Model Serializer]

    validates :untrash_activity, presence: true
  end
end
