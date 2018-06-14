# frozen_string_literal: true

module MarkAsImportant
  module Model
    extend ActiveSupport::Concern

    included do
      attribute :mark_as_important, :boolean
    end

    def mark_as_important
      argu_publication&.follow_type&.to_s == 'news'
    end
  end
end
