# frozen_string_literal: true

module Trashable
  module Action
    extend ActiveSupport::Concern

    included do
      include LinkedRails::Enhancements::Destroyable::Action

      has_resource_trash_action
      has_resource_untrash_action
    end
  end
end
