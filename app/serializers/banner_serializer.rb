# frozen_string_literal: true

class BannerSerializer < EdgeSerializer
  attribute :description, predicate: NS::SCHEMA[:text]
  attribute :dismiss_button, predicate: NS::ONTOLA[:dismissButton]
  attribute :dismiss_action, predicate: NS::ONTOLA[:dismissAction]
  enum :audience, predicate: NS::ONTOLA[:audience]
end
