# frozen_string_literal: true

module MarkAsImportant
  module Model
    extend ActiveSupport::Concern

    included do
      enhance ActivePublishable

      attribute :mark_as_important, :boolean
    end

    def mark_as_important
      argu_publication&.persisted? && argu_publication&.follow_type&.to_s == 'news'
    end
    alias mark_as_important? mark_as_important
  end
end
