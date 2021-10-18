# frozen_string_literal: true

module Followable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :follows
    end

    def follow_iri(follow_type)
      collection_iri(:follows, follow_type: follow_type)
    end
  end
end
