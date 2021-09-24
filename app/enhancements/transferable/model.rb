# frozen_string_literal: true

module Transferable
  module Model
    extend ActiveSupport::Concern

    included do
      include UUIDHelper

      attr_accessor :transfer_to
    end

    def transfer!(transfer_to)
      new_owner = LinkedRails.iri_mapper.resource_from_iri(transfer_to, nil)&.profile
      return false unless new_owner.is_a?(Profile)

      update!(creator: new_owner)
      transfer_publication
      transfer_activities

      true
    end

    private

    def transfer_activities
      activities
        .where(key: %W[#{self.class.name.underscore}.create #{self.class.name.underscore}.publish])
        .find_each { |a| a.update!(owner: new_owner) }
    end

    def transfer_publication
      argu_publication.update!(creator: new_owner)
    end
  end
end
