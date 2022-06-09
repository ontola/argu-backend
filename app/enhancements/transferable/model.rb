# frozen_string_literal: true

module Transferable
  module Model
    extend ActiveSupport::Concern

    included do
      include UUIDHelper

      attr_accessor :transfer_to, :transfer_type

      enum transfer_type: {transfer_to_page: 0, transfer_to_user: 1}
    end

    def transfer!(transfer_to)
      new_owner = LinkedRails.iri_mapper.resource_from_iri(transfer_to, nil)&.profile
      return false unless new_owner.is_a?(Profile)

      update!(creator: new_owner)
      transfer_publication(new_owner)
      transfer_activities(new_owner)

      true
    end

    private

    def transfer_activities(new_owner)
      activities
        .where(key: %W[#{self.class.name.underscore}.create #{self.class.name.underscore}.publish])
        .find_each { |a| a.update!(owner: new_owner) }
    end

    def transfer_publication(new_owner)
      argu_publication.update!(creator: new_owner)
    end
  end
end
