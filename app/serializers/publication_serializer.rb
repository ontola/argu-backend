# frozen_string_literal: true

class PublicationSerializer < BaseSerializer
  attribute :draft, predicate: NS::ARGU[:draft]
end
