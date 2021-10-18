# frozen_string_literal: true

module RootGrantable
  module Model
    extend ActiveSupport::Concern

    included do
      after_create :create_default_grant
      accepts_nested_attributes_for :grants, reject_if: :all_blank, allow_destroy: true

      attr_writer :initial_public_grant

      private

      def create_default_grant
        grants.where(group_id: Group::PUBLIC_ID).destroy_all

        grant_set = @initial_public_grant || self.class.default_public_grant
        return unless grant_set

        grants.create!(
          group_id: Group::PUBLIC_ID,
          grant_set: GrantSet.find_by!(title: grant_set)
        )
      end
    end

    class_methods do
      def default_public_grant; end
    end
  end
end
