# frozen_string_literal: true

module Users
  class Password < VirtualResource
    include Ldable
    include Iriable
    enhance Actionable
    enhance Createable, except: %i[Controller]
    attr_accessor :email

    def iri_template_name
      :passwords_iri
    end

    alias identifier class_name

    def new_record?
      false
    end
  end
end
