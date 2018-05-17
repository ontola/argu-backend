# frozen_string_literal: true

module ContentEdgeable
  extend ActiveSupport::Concern

  included do
    include Loggable
    include Trashable
    include Menuable

    def capitalize_title
      title[0] = title[0].upcase
      title
    end
  end
end
