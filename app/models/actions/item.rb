# frozen_string_literal: true

module Actions
  class Item < LinkedRails::Actions::Item
    attr_writer :target

    def error
      return super unless action_status == NS::ONTOLA[:DisabledActionStatus]

      resource_policy.message || super
    end
  end
end
