# frozen_string_literal: true

module Users
  class Confirmation < VirtualResource
    include RailsLD::Model
    enhance Actionable
    enhance Createable, except: %i[Controller]
    attr_accessor :email, :user

    def iri_template_name
      :confirmations_iri
    end

    alias identifier class_name

    def new_record?
      true
    end
  end
end
