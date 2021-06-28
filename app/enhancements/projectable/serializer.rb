# frozen_string_literal: true

module Projectable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :projects, predicate: NS.argu[:projects]
    end
  end
end
