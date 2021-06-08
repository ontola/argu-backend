# frozen_string_literal: true

module Users
  class Confirmation < LinkedRails::Auth::Confirmation
    include UriTemplateHelper

    attr_accessor :email

    delegate :confirm!, :confirmed?, to: :email!

    def confirm!
      email!.confirm
    end

    def email!
      email || raise(ActiveRecord::RecordNotFound)
    end

    class << self
      def iri_value
        name.demodulize
      end

      def form_class
        LinkedRails::Auth::ConfirmationForm
      end

      def policy_class
        LinkedRails::Auth::ConfirmationPolicy
      end
    end
  end
end
