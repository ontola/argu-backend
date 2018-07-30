# frozen_string_literal: true

module ActiveRecord
  class LogSubscriber < ActiveSupport::LogSubscriber
    def ignored_callstack(path)
      path.start_with?(RAILS_GEM_ROOT) ||
        path.start_with?(RbConfig::CONFIG['rubylibdir']) ||
        path.include?('app/models/edgeable/properties.rb')
    end
  end
end
