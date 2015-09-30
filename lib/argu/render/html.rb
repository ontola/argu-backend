module Argu
  module Render
    class HTML < Redcarpet::Render::HTML
      def initialize(extensions = {})
        super extensions.merge(link_attributes: { target: "_blank" })
      end
    end
  end
end
