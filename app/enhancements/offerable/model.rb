# frozen_string_literal: true

module Offerable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :linked_offers,
               primary_key_property: :product_id,
               class_name: 'Offer',
               dependent: false
    end

    def publish_update
      linked_offers.each(&:publish_update)

      super
    end
  end
end
