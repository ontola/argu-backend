module ArguExtensions
  module Context
    # Descends down the context tree until a forum is found.
    def context_scope(current_profile)
      redis = Redis.new
      if self.present?
        if self.model.class == Forum
          redis.set("profiles.#{current_profile.id}.last_forum", self.model.id)
          self
        elsif self.parent.present?
          self.parent.context_scope
        end
      else
        last_forum = redis.get("profiles.#{current_profile.id}.last_forum") if current_profile
        ::Context.new last_forum.present? ? Forum.find(last_forum) : Forum.first_public
      end
    end

    def self.extended(base)
      base.include self
    end
  end
end

::Context.send :extend, ArguExtensions::Context