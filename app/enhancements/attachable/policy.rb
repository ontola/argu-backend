# frozen_string_literal: true

module Attachable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_nested_attributes %i[attachments]
    end
  end
end
