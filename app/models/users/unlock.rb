# frozen_string_literal: true

module Users
  class Unlock < VirtualResource
    include RailsLD::Model
    enhance Actionable
    enhance Createable, except: %i[Controller]
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
