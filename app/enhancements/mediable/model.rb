# frozen_string_literal: true

module Mediable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :media_objects, as: :about, inverse_of: :about, dependent: :destroy, primary_key: :uuid
    end
  end
end
