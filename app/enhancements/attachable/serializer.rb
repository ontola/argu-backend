# frozen_string_literal: true

module Attachable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :attachments, predicate: NS::ARGU[:attachments]
    end
  end
end
