module Loggable
  extend ActiveSupport::Concern

  included do
    has_many :activities,
             -> { where("key ~ '*.!happened'") },
             as: :trackable
    has_one :created_activity,
            -> { where("key ~ '*.create'") },
            class_name: 'Activity',
            as: :trackable
  end

  module Serlializer
    extend ActiveSupport::Concern
    included do
      link(:log) { log_url(object.edge) }
    end
  end
end
