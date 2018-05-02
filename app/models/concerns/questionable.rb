# frozen_string_literal: true

module Questionable
  extend ActiveSupport::Concern

  included do
    with_collection :questions, pagination: true
  end

  module Actions
    extend ActiveSupport::Concern

    included do
      include ActionableHelper

      define_default_create_action :question, image: 'fa-question'
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :questions, predicate: NS::ARGU[:questions]
    end
  end
end
