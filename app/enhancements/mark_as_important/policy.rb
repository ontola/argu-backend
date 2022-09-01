# frozen_string_literal: true

module MarkAsImportant
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[mark_as_important],
                        grant_sets: %i[moderator administrator],
                        has_values: {mark_as_important?: false}
      permit_attributes %i[mark_as_important],
                        grant_sets: %i[moderator administrator],
                        has_properties: {published_at: false}
    end
  end
end
