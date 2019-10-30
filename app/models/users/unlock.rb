# frozen_string_literal: true

module Users
  class Unlock < VirtualResource
    include LinkedRails::Model
    enhance LinkedRails::Enhancements::Actionable
    enhance LinkedRails::Enhancements::Creatable, except: %i[Controller]
    enhance LinkedRails::Enhancements::Updatable, except: %i[Controller Serializer]
    attr_accessor :email

    def iri_template_name
      :user_unlock
    end

    alias identifier class_name

    def new_record?
      false
    end
  end
end
