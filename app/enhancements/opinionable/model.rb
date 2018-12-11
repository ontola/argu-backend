# frozen_string_literal: true

module Opinionable
  module Model
    extend ActiveSupport::Concern

    def opinion_for(user)
      vote_for(user)&.comment
    end
  end
end
