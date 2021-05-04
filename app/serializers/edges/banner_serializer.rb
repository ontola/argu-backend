# frozen_string_literal: true

class BannerSerializer < EdgeSerializer
  attribute :dismiss_action, predicate: NS::ONTOLA[:dismissAction]
end
