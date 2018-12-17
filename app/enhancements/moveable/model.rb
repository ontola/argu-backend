# frozen_string_literal: true

module Moveable
  module Model
    extend ActiveSupport::Concern

    def move_to(new_parent) # rubocop:disable Metrics/AbcSize
      self.class.transaction do
        yield if block_given?
        update_activities_on_move(new_parent)
        if root_id != new_parent.root_id
          self.fragment = nil
          self.root_id = new_parent.root_id
          @root = new_parent.root
          descendants.update_all(root_id: new_parent.root_id)
          shortnameable? && shortname.update(root_id: new_parent.root_id)
        end
        self.parent = new_parent
        save!
      end
      true
    end

    private

    def update_activities_on_move(new_parent)
      return unless is_loggable? && new_parent.ancestor(:forum) != ancestor(:forum)
      activities
        .lock(true)
        .update_all(
          recipient_id: new_parent.id,
          recipient_type: new_parent.owner_type
        )
    end
  end
end
