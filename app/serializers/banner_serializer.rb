# frozen_string_literal: true

class BannerSerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA[:text]
  attribute :audience, predicate: NS::ONTOLA[:audience]
  attribute :dismiss_button, predicate: NS::ONTOLA[:dismissButton]
  attribute :dismiss_action, predicate: NS::ONTOLA[:dismissAction]

  enum :audience
end
