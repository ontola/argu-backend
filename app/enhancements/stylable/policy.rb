# frozen_string_literal: true

module Stylable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes(
        %i[navbar_color navbar_background accent_color accent_background_color styled_headers],
        new_record: false
      )
    end
  end
end
