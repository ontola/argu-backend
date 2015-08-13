module ArguExtensions
  module Context
    # Descends down the context tree until a forum is found.
    def context_scope(current_profile, default_nil = false)
      @redis ||= Redis.new
      if self.present?
        if self.model.class == Forum
          begin
            @redis.set("profiles:#{current_profile.id}:last_forum", self.model.id) if current_profile && current_profile.memberships.pluck(:forum_id).include?(self.model.id)
          rescue RuntimeError => e
            Rails.logger.error 'Redis not available'
            ::Bugsnag.notify(e, {
                :severity => 'error',
            })
          end
          self
        elsif self.parent.present?
          self.parent.context_scope(current_profile)
        end
      else
        if default_nil
          ::Context.new
        else
          ::Context.new current_profile.present? ? current_profile.preferred_forum : Forum.first_public
        end
      end
    end

    def self.extended(base)
      base.include self
    end
  end
end

::Context.send :extend, ArguExtensions::Context
