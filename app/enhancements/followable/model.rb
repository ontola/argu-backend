# frozen_string_literal: true

module Followable
  module Model
    extend ActiveSupport::Concern

    def follow_iri(follow_type)
      collection_iri(self, :follows, follow_type: follow_type)
    end
  end
end
