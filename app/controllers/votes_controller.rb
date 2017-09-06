# frozen_string_literal: true

class VotesController < EdgeTreeController
  include UriTemplateHelper
  skip_before_action :check_if_registered, only: %i[index show create destroy]

  # GET /model/:model_id/vote
  def show
    respond_to do |format|
      format.html { redirect_to url_for(authenticated_resource.parent_model) }
      format.json { render 'create', location: authenticated_resource }
      format.json_api { render json: authenticated_resource, include: :upvoted_arguments }
      format.n3 { render n3: authenticated_resource, include: :upvoted_arguments }
    end
  end

  def new
    render locals: {
      resource: parent_resource!.voteable,
      vote: Vote.new
    }
  end

  # POST /model/:model_id/v/:for
  def create
    return super unless unmodified?
    respond_to do |format|
      format.json do
        render status: 304,
               locals: {model: create_service.resource.parent_model.voteable, vote: create_service.resource}
      end
      format.json_api { respond_with_304(create_service.resource, :json_api) }
      format.n3 { respond_with_304(create_service.resource, :n3) }
      format.js { render locals: {model: create_service.resource.parent_model, vote: create_service.resource} }
      format.html do
        if params[:vote].try(:[], :r).present?
          redirect_to redirect_param
        else
          redirect_to polymorphic_url(create_service.resource.parent_model.voteable),
                      notice: t('votes.alerts.not_modified')
        end
      end
    end
  end

  private

  def authorize_action
    return super unless action_name == 'create'
    method = authenticated_resource.persisted? ? :update? : :create?
    authorize authenticated_resource, method
  end

  def respond_with_201(resource, format)
    case format
    when :json
      render locals: {model: resource.parent_model, vote: resource}, status: :created, location: vote_url(resource)
    else
      super
    end
  end

  def create_respond_failure_html(resource)
    redirect_to polymorphic_url(resource.parent_model.voteable),
                notice: t('votes.alerts.failed')
  end

  def create_respond_success_html(resource)
    if params[:vote].try(:[], :r).present?
      redirect_to redirect_param
    else
      redirect_to polymorphic_url(resource.parent_model.voteable),
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

  def resource_by_id
    return super unless %w[show destroy].include?(params[:action]) && params[:id].nil?
    @_resource_by_id ||= Edge
                           .where_owner('Vote', creator: current_profile)
                           .find_by(parent: parent_from_params.edge)
                           &.owner
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
    super.try(:default_vote_event) || super
  end

  def unmodified?
    create_service.resource.persisted? &&
      !create_service.resource.for_changed? &&
      !create_service.resource.explanation_changed? &&
      create_service.resource.argument_ids == create_service.resource.upvoted_arguments.pluck(:id)
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

  def redirect_url
    expand_uri_template(
      :new_vote,
      voteable_path: url_for([parent_resource!.voteable, only_path: true]).split('/').select(&:present?),
      confirm: true,
      r: params[:r],
      'vote%5Bfor%5D' => for_param,
      path_only: true
    )
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      publisher: current_user,
      for: for_param
    )
  end
end
