# frozen_string_literal: true

module GrantResettable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[reset_create_motion]
      permit_array_attributes %i[create_motion_group_ids]
    end
  end
end
