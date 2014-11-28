module ArguExtensions
  module Context
    # Descends down the context tree until a forum is found.
    def context_scope
      if self.present?
        if self.model.class == Forum
          self
        elsif self.parent.present?
          self.parent.context_scope
        end
      end
    end

    def self.extended(base)
      base.include self
    end
  end
end

::Context.send :extend, ArguExtensions::Context