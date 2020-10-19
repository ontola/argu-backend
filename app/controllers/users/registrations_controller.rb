# frozen_string_literal: true

module Users
  class RegistrationsController < LinkedRails::Auth::RegistrationsController
    include Argu::Controller::Authorization
    include RedisResourcesHelper
    include OauthHelper

    private

    def create_success
      super

      guest_user = GuestUser.new(id: session_id)
      mail_sent = send_confirmation_mail(
        current_resource,
        RedisResource::Relation.where(publisher: guest_user, parent: {owner_type: 'VoteEvent'})
      )
      current_resource.send_reset_password_token_email unless mail_sent
      schedule_redis_resource_worker(guest_user, current_resource, current_resource.redirect_url) if session_id.present?
    end

    def create_success_location
      if current_resource.redirect_url
        current_resource.redirect_url
      elsif current_resource.url
        edit_user_url(current_resource.url)
      else
        iri_from_template(:setup_iri).path
      end
    end

    def new_resource
      resource = super
      resource.shortname = nil if resource.shortname&.shortname.blank?
      resource.build_profile
      resource.language = I18n.locale
      resource
    end

    def permit_param_key
      params.key?(:user) ? :user : controller_name.singularize
    end

    def send_confirmation_mail(user, guest_votes) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      if guest_votes&.count&.positive?
        SendEmailWorker.perform_async(
          :confirm_votes,
          user.id,
          token_url: user_confirmation_url(user),
          motions: guest_votes.map do |guest_vote|
            m = guest_vote.resource.ancestor(:motion)
            {display_name: m.display_name, url: m.iri, option: guest_vote.resource.option} if m
          end.compact
        )
      elsif user.password.present?
        SendEmailWorker.perform_async(:confirmation, user.id, token_url: user_confirmation_url(user))
      end
    end

    def user_confirmation_url(user)
      iri_from_template(:user_confirmation, confirmation_token: user.confirmation_token)
    end
  end
end