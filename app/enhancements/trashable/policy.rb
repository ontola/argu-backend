# frozen_string_literal: true

module Trashable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_nested_attributes %i[trash_activity untrash_activity]
    end
  end
end
