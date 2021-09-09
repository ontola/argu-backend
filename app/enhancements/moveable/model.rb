# frozen_string_literal: true

module Moveable
  module Model
    extend ActiveSupport::Concern

    def move_to(new_parent_id)
      new_parent = new_parent_from_id(new_parent_id)

      self.class.transaction do
        yield if block_given?
        update_activities_on_move(new_parent)
        self.parent = new_parent
        save!
      end

      true
    end

    private

    def new_parent_from_id(new_parent_id)
      return Edge.find_by!(uuid: new_parent_id) if uuid?(new_parent_id)

      LinkedRails.iri_mapper.resource_from_iri!(new_parent_id, nil)
    end

    def update_activities_on_move(new_parent)
      return unless is_loggable? && new_parent.ancestor(:forum) != ancestor(:forum)

      # rubocop:disable Rails/SkipsModelValidations
      activities
        .lock(true)
        .update_all(
          recipient_edge_id: new_parent.uuid,
          recipient_type: new_parent.owner_type
        )
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
