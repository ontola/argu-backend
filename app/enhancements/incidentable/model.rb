# frozen_string_literal: true

module Incidentable
  module Model
    extend ActiveSupport::Concern

    included do
      enhance Scenariable
      has_many_children :scenarios, through: :incidents

      with_collection :incidents
    end
  end
end
