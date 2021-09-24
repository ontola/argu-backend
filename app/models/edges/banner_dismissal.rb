# frozen_string_literal: true

class BannerDismissal < Edge
  include DeltaHelper
  include RedisResource::Concern

  enhance LinkedRails::Enhancements::Creatable
  parentable :banner

  def added_delta
    [
      [parent.iri, NS.ontola[:dismissedAt], Time.current, delta_iri(:replace)]
    ]
  end

  def self.store_in_redis?(**_opts)
    true
  end
end
