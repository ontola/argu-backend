module ArguExtensions
  module Context
    # Descends down the context tree until a forum is found.
    def context_scope(current_profile)
      @redis ||= Redis.new
      if self.present?
        if self.model.class == Forum
          @redis.set("profiles.#{current_profile.id}.last_forum", self.model.id) if current_profile
          self
        elsif self.parent.present?
          self.parent.context_scope(current_profile)
        end
      else
        ::Context.new current_profile.present? ? current_profile.preferred_forum : Forum.first_public
      end
    end

    def self.extended(base)
      base.include self
    end
  end
end

::Context.send :extend, ArguExtensions::Context