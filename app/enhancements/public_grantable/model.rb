# frozen_string_literal: true

module PublicGrantable
  module Model
    extend ActiveSupport::Concern

    included do
      attr_writer :public_grant

      after_save :reset_public_grant
    end

    def default_public_grant; end

    def public_grant
      @public_grant ||=
        grants.find_by(group_id: Group::PUBLIC_ID)&.grant_set&.title&.to_sym || default_public_grant || :none
    end

    private

    def reset_public_grant # rubocop:disable Metrics/AbcSize
      return if @public_grant.blank? && default_public_grant.blank?

      if public_grant&.to_sym == :none
        grants.where(group_id: Group::PUBLIC_ID).destroy_all
      else
        grants.joins(:grant_set).where('group_id = ? AND title != ?', Group::PUBLIC_ID, public_grant).destroy_all
        unless grants.joins(:grant_set).find_by(group_id: Group::PUBLIC_ID, grant_sets: {title: public_grant})
          grants.create!(group_id: Group::PUBLIC_ID, grant_set: GrantSet.find_by!(title: public_grant))
        end
      end
    end
  end
end
