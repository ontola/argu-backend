# frozen_string_literal: true

module Exportable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :exports
    end
  end
end
