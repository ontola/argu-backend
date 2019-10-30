# frozen_string_literal: true

module Users
  class Password < VirtualResource
    include LinkedRails::Model
    enhance LinkedRails::Enhancements::Actionable
    enhance LinkedRails::Enhancements::Creatable, except: %i[Controller]
    enhance LinkedRails::Enhancements::Updatable, except: %i[Controller Serializer]
    attr_accessor :email, :password, :password_confirmation, :user, :reset_password_token

    def iri_template_name
      :passwords_iri
    end

    alias identifier class_name

    def new_record?
      false
    end
  end
end
