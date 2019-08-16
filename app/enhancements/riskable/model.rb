# frozen_string_literal: true

module Riskable
  module Model
    extend ActiveSupport::Concern

    included do
      property :example_of_id, :linked_edge_id, NS::RIVM[:exampleOf], default: nil, array: true

      has_many :example_of, foreign_key_property: :example_of_id, class_name: 'Risk', dependent: false

      with_collection :risks, association: :example_of
    end

    def risks_id=(ids)
      self.example_of_id =
        (ids.is_a?(Array) ? ids : [ids]).map do |id|
          uuid?(id) ? id : Shortname.find_by!(root_id: ActsAsTenant.current_tenant.uuid, shortname: id).owner_id
        end
    end
  end
end
