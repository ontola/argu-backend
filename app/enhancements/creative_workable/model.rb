# frozen_string_literal: true

module CreativeWorkable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :creative_works
    end
  end
end
