# frozen_string_literal: true

module Motionable
  extend ActiveSupport::Concern

  included do
    with_collection :motions, pagination: true
  end

  module Actions
    extend ActiveSupport::Concern

    included do
      include ActionableHelper

      define_default_create_action :motion, image: 'fa-motion'
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :motions, predicate: NS::ARGU[:motions]
    end
  end
end
