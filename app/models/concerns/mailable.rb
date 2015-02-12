module Mailable
  extend ActiveSupport::Concern

  included do
    def mailable?
      true
    end
  end


  module ClassMethods
    def mailable?
      true
    end

    def mailable(mailer, *options)
      cattr_accessor :mailer do
        mailer
      end
      options.each do |o|
        cattr_accessor o do
          true
        end
      end
    end
  end
end
