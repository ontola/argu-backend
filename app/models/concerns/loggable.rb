# Concern for Models that use Activities to keep a log of changes
module Loggable
  extend ActiveSupport::Concern

  included do
    has_many :activities,
             -> { where("key ~ '*.!happened'") },
             as: :trackable
  end

  module Serlializer
    extend ActiveSupport::Concern
    included do
      link(:log) { log_url(object.edge) }
    end
  end
end
