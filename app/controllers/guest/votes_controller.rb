# frozen_string_literal: true
module Guest
  class VotesController < ActionController::Base
    include NestedResourceHelper, Pundit, JsonApiHelper
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from Argu::NotAuthorizedError, with: :handle_not_authorized_error

    # GET /model/:model_id/vote
    def show
      authorize authenticated_resource, :show?
      respond_to do |format|
        format.json do
          render json: authenticated_resource
        end
        format.json_api do
          render json: authenticated_resource
        end
      end
    end

    # Create a temporary vote within this session
    def create
      unless policy(get_parent_resource).create_child?(:votes)
        raise Argu::NotAuthorizedError.new(query: 'create?')
      end
      is_update = authenticated_resource.created_at.present?
      authenticated_resource.created_at = DateTime.current
      Argu::Redis.set(
        key,
        {
          created_at: authenticated_resource.created_at,
          id: authenticated_resource.id,
          for: authenticated_resource.for
        }.to_json
      )
      Argu::Redis.expire(key, 3.hours.to_i)
      DataEvent.publish(authenticated_resource)
      head is_update ? 200 : 201
    end

    private

    def authenticated_resource
      @resource ||=
        case action_name
        when 'create'
          current_vote || new_resource_from_params
        else
          current_vote!
        end
    end

    def new_resource_from_params
      Vote.new(
        id: ActiveRecord::Base.connection.execute("SELECT nextval('votes_id_seq'::regclass)").first['nextval'],
        voteable_id: get_parent_resource.id,
        voteable_type: get_parent_resource.class.name,
        'for': params[:vote][:for],
        creator: current_user.profile,
        edge: Edge.new(parent: get_parent_resource.edge)
      )
    end

    def current_user
      GuestUser.new(session: session)
    end

    def current_vote
      raw = Argu::Redis.get(key)
      vote = raw && JSON.parse(raw)
      return if vote.nil?
      Vote.new(
        created_at: vote['created_at'],
        id: vote['id'],
        voteable_id: get_parent_resource.id,
        voteable_type: get_parent_resource.class.name,
        for: vote['for'],
        creator: current_user.profile,
        edge: Edge.new(parent: get_parent_resource.edge)
      )
    rescue JSON::ParserError
      nil
    end

    def current_vote!
      current_vote || raise(ActiveRecord::RecordNotFound)
    end

    def get_parent_resource
      @parent_resource ||= super.try(:default_vote_event) || super
    end

    def handle_not_authorized_error(exception)
      @_not_authorized_caught = true
      Rails.logger.error exception
      error_hash = {
        type: :error,
        error_id: 'NOT_AUTHORIZED',
        message: exception.message
      }
      respond_to do |format|
        format.json do
          render status: 403,
                 json: error_hash.merge(notifications: [error_hash])
        end
        format.json_api do
          error_hash = {
            message: exception.message,
            code: 'NOT_AUTHORIZED'
          }
          render json_api_error(403, error_hash)
        end
      end
    end

    def handle_record_not_found(_exception)
      respond_to do |format|
        format.json do
          render status: 404,
                 json: {
                   title: t('status.s_404.header'),
                   message: t('status.s_404.body'),
                   quote: @quote
                 }
        end
        format.json_api { render json_api_error(404) }
      end
    end

    def key
      "guest.#{controller_name}.#{get_parent_resource.class.name.tableize}.#{get_parent_resource.id}.#{session.id}"
    end

    def pundit_user
      UserContext.new(
        current_user,
        current_user.profile,
        'guest',
        session[:a_tokens]
      )
    end
  end
end
