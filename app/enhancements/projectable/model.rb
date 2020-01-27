# frozen_string_literal: true

module Projectable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :projects
    end
  end
end
