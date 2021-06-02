# frozen_string_literal: true

class Banner < BannerManagement
  with_collection :banner_dismissals

  class << self
    def iri_namespace
      NS::ONTOLA
    end
  end
end
