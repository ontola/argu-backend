# frozen_string_literal: true

module Bannerable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :banners,
               foreign_key: :parent_id,
               inverse_of: :parent,
               dependent: :destroy
      has_many :banner_managements,
               foreign_key: :parent_id,
               inverse_of: :parent
      with_collection :banners,
                      association: :banners
      with_collection :banner_managements,
                      association: :banner_managements
    end
  end
end
