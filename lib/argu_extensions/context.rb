module ArguExtensions
  module Context
    # Descends down the context tree until a forum is found.
    def context_scope(current_profile, default_nil = false)
      if present?
        if model.class == Forum
          if current_profile && current_profile.memberships.pluck(:forum_id).include?(model.id)
            Argu::Redis.set("profile:#{current_profile.id}:last_forum", model.id)
          end
          self
        elsif parent.present?
          parent.context_scope(current_profile)
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
