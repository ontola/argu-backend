# frozen_string_literal: true

class EdgeSerializer < ContentEdgeSerializer
  link(:log) do
    {
      href: log_url(object),
      meta: {
        predicate: NS::ARGU[:log]
      }
    }
  end

  def type
    NS::ARGU[object.owner_type]
  end
end
