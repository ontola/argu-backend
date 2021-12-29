# frozen_string_literal: true

class UserContext
  class ChildCache
    def initialize
      @cache = {}
    end

    def build_child(parent, klass)
      cached_child(parent, klass) || cache_child(parent, klass)
    end

    private

    def cache_child(parent, klass)
      @cache[cache_key(parent, klass)] ||=
        parent.build_child(klass, user_context: self)
    end

    def cached_child(parent, klass)
      @cache[cache_key(parent, klass)]
    end

    def cache_key(parent, klass)
      "#{parent.identifier}-#{klass}"
    end
  end
end
