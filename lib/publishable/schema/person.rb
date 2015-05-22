module Publishable

  module Schema
    module Person
      include Thing
      attr_accessor :additional_name, :family_name, :given_name, :gender
    end
  end

end
