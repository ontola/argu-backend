# frozen_string_literal: true

class Banner < BannerManagement
  class << self
    def iri_namespace
      NS.ontola
    end
  end
end
