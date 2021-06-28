# frozen_string_literal: true

class BannerSerializer < EdgeSerializer
  attribute :dismiss_action, predicate: NS.ontola[:dismissAction]
end
