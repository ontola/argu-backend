# frozen_string_literal: true

module Stylable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes(
        %i[header_background header_text secondary_color primary_color styled_headers],
        new_record: false
      )
    end
  end
end
