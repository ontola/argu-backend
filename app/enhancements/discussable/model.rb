# frozen_string_literal: true

module Discussable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :discussions,
               -> { where(owner_type: %w[Motion Question]) },
               class_name: 'Edge',
               foreign_key: :parent_id,
               inverse_of: :parent

      with_collection :discussions
    end
  end
end
