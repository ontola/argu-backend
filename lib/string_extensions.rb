# frozen_string_literal: true
module StringExtensions
  refine String do
    def constantize_with_care(list_of_klasses = [])
      list_of_klasses.each do |klass|
        return safe_constantize if self == klass.to_s
      end
      raise "Not allowed to constantize #{self}!"
    end
  end
end
