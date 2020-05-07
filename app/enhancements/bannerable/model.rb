# frozen_string_literal: true

module Bannerable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :banners,
               foreign_key: :parent_id,
               inverse_of: :parent,
               dependent: :destroy
      has_many :active_banners,
               foreign_key: :parent_id,
               inverse_of: :parent
      with_collection :banners,
                      association: :banners
      with_collection :active_banners,
                      association: :active_banners,
                      parent_uri_template: :banners_collection_iri,
                      parent_uri_template_canonical: :banners_collection_canonical
    end
  end
end
