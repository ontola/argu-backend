# frozen_string_literal: true

module ContentEdgeable
  extend ActiveSupport::Concern

  included do
    include Actionable
    include Loggable
    include Trashable
    include Menuable

    belongs_to :creator, class_name: 'Profile', inverse_of: class_name
    belongs_to :forum, inverse_of: class_name
    belongs_to :publisher, class_name: 'User', inverse_of: class_name

    def capitalize_title
      title.capitalize!
    end
  end
end
