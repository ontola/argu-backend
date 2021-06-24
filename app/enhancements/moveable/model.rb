# frozen_string_literal: true

module Moveable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :moves

      def moves
        []
      end
    end

    def move_to(new_parent)
      self.class.transaction do
        yield if block_given?
        update_activities_on_move(new_parent)
        self.parent = new_parent
        save!
      end
      true
    end

    private

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

    def update_root_id(new_root_id)
      self.root_id = new_root_id
    rescue ActsAsTenant::Errors::TenantIsImmutable
      nil
    end
  end
end
