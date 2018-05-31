# frozen_string_literal: true

class VotesController < EdgeableController
  include UriTemplateHelper
  skip_before_action :check_if_registered, only: %i[index show create destroy]

  def new
    render locals: {
      resource: parent_resource!,
      vote: Vote.new
    }
  end

  # POST /model/:model_id/votes/:for
  def create
    return super unless unmodified?
    respond_to do |format|
      format.html do
        if params[:vote].try(:[], :r).present?
          redirect_to redirect_param
        else
          redirect_to create_service.resource.parent_model.voteable.iri(only_path: true).to_s,
                      notice: t('votes.alerts.not_modified')
        end
      end
      format.json do
        render status: 304,
               locals: {model: create_service.resource.parent_model.voteable, vote: create_service.resource}
      end
      format.json_api { respond_with_304(create_service.resource, :json_api) }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { respond_with_304(create_service.resource, type) }
      end
      format.js { render locals: {model: create_service.resource.parent_model, vote: create_service.resource} }
    end
  end

  private

  def authorize_action
    return super unless action_name == 'create'
    method = authenticated_resource.persisted? ? :update? : :create?
    authorize authenticated_resource, method
  end

  def respond_with_201(resource, format, _opts = {})
    case format
    when :json
      render locals: {model: resource.parent_model, vote: resource}, status: :created, location: resource.iri_path
    else
      super
    end
  end

  def create_respond_failure_html(resource)
    redirect_to resource.parent_model.voteable.iri(only_path: true).to_s,
                notice: t('votes.alerts.failed')
  end

  def create_respond_success_html(resource)
    if params[:vote].try(:[], :r).present?
      redirect_to redirect_param
    else
      redirect_to resource.parent_model.voteable.iri(only_path: true).to_s,
                  notice: t('votes.alerts.success')
    end
  end

  def create_respond_success_js(resource)
    return super(resource.parent_model.voteable) unless resource.parent_model.is_a?(Argument)
    render locals: {model: resource.parent_model, vote: resource}
  end

  def destroy_respond_success_js(resource)
    render locals: {
      vote: resource
    }
  end

  def include_index
    [
      view_sequence: [
        members:
          [
            member_sequence: :members,
            operation: :target,
            view_sequence: [members: [member_sequence: :members, operation: :target].freeze].freeze
          ].freeze
      ].freeze
    ].freeze
  end

  def include_create
    [:partOf, voteable: :actions]
  end

  def resource_by_id
    return super unless %w[show destroy].include?(params[:action]) && params[:id].nil?
    @_resource_by_id ||=
      Edge
        .where_owner('Vote', creator: current_profile, root_id: root_from_params&.uuid)
        .find_by(parent: parent_resource)
  end

  def show_respond_success_html(resource)
    redirect_to resource.voteable.iri(only_path: true).to_s
  end

  def for_param
    if params[:for].is_a?(String) && params[:for].present?
      # Still used for upvoting arguments
      warn '[DEPRECATED] Using direct params is deprecated, please use proper nesting instead.'
      param = params[:for]
    elsif params[:vote].is_a?(ActionController::Parameters)
      param = params[:vote][:for]
    end
    param.present? && param !~ /\D/ ? Vote.fors.key(param.to_i) : param
  end

  def parent_from_params(opts = params)
    return super unless params[:vote_event_id] == VoteEvent::DEFAULT_ID
    super(opts.except(:vote_event_id))&.default_vote_event if parent_resource_key(opts.except(:vote_event_id))
  end

  def linked_record_parent(opts = params)
    return super unless params[:vote_event_id] == VoteEvent::DEFAULT_ID
    super(opts.except(:vote_event_id))&.default_vote_event
  end

  def unmodified?
    create_service.resource.persisted? && !create_service.resource.for_changed?
  end

  def deserialize_params_options
    {keys: {side: :for}}
  end

  def permit_params
    return super if params[:vote].present?
    params.permit(:id)
  end

  def redirect_param
    params.require(:vote).permit(:r)[:r]
  end

  def redirect_model_success(resource)
    resource.persisted? ? resource.iri(only_path: true).to_s : resource.voteable.iri(only_path: true).to_s
  end

  def redirect_url
    expand_uri_template(
      :new_vote,
      voteable_path: parent_resource!.iri(only_path: true).to_s.split('/').select(&:present?),
      confirm: true,
      r: params[:r],
      'vote%5Bfor%5D' => for_param,
      only_path: true
    )
  end

  def resource_new_params
    super.merge(
      for: for_param,
      primary: true
    )
  end

  def meta_create
    data = []
    if authenticated_resource.parent_model.is_a?(VoteEvent)
      parent_collection = index_collection.send(:child_with_options, filter: nil)
      meta_increment_collection_count(data, parent_collection.iri, parent_collection.total_count)
      parent_collection.views.each do |view|
        if view == index_collection
          meta_increment_collection_count(data, view.iri, view.total_count)
        else
          meta_decrement_collection_count(data, view.iri, view.total_count)
        end
      end
    else
      data = super
    end
    data
  end

  def meta_destroy
    data = super
    data.push [
      authenticated_resource.parent_iri,
      NS::ARGU[:currentVote],
      authenticated_resource.iri,
      NS::LL[:remove]
    ]
    if authenticated_resource.parent_model.is_a?(Argument)
      data.push [
        authenticated_resource.parent_iri,
        NS::ARGU[:votesProCount],
        authenticated_resource.parent_edge.children_counts['votes_pro'].to_i - 1,
        NS::LL[:replace]
      ]
    end
    data.push [
      authenticated_resource.parent_iri,
      NS::HYDRA[:operation],
      RDF::URI("#{authenticated_resource.parent_iri}/actions/destroy_vote"),
      NS::LL[:remove]
    ]
    data.push [
      authenticated_resource.parent_iri,
      NS::HYDRA[:operation],
      RDF::URI("#{authenticated_resource.parent_iri}/actions/create_vote"),
      NS::LL[:add]
    ]
  end
end
