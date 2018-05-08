# frozen_string_literal: true

class ShortnamesController < ParentableController
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique

  SAFE_OWNER_TYPES = %w[Question Motion Argument Comment].freeze

  def create
    if execute_update
      create_handler_success(authenticated_resource)
    else
      create_handler_failure(authenticated_resource)
    end
  end

  private

  def authenticated_edge
    authenticated_resource.owner.edge
  end

  def tree_root_id
    @tree_root_id ||=
      case action_name
      when 'new', 'create', 'index'
        parent_edge.root_id
      else
        resource_by_id&.owner&.edge&.root_id
      end
  end

  def parent_resource
    @parent_resource ||=
      if %w[new create].include?(params[:action])
        super
      else
        resource_by_id&.forum
      end
  end

  def handle_record_not_unique_html
    authenticated_resource
      .errors
      .add(:owner, t('activerecord.errors.record_not_unique'))
    respond_with_form(authenticated_resource)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(forum: parent_resource!)
  end

  def permit_params
    attrs = policy(resource_by_id || new_resource_from_params)
              .permitted_attributes
    p = params
          .require(:shortname)
          .permit(*attrs)
    p['owner_type'] = nil unless SAFE_OWNER_TYPES.include?(p['owner_type'])
    p
  end

  def redirect_model_success(_resource = nil)
    settings_iri_path(parent_resource!, tab: 'shortnames')
  end

  def respond_with_form(resource)
    render 'forums/settings',
           locals: {
             tab: "shortnames/#{tab}",
             active: 'shortnames',
             shortname: resource,
             resource: resource.forum
           }
  end

  def respond_with_redirect_success(_resource = nil, _action = nil, opts = {})
    redirect_to redirect_model_success, opts
  end

  def resource_by_id
    @resource ||= Shortname.find_by(id: params[:id])
  end

  def tab
    case action_name
    when 'create', 'new'
      :new
    when 'edit', 'update'
      :edit
    end
  end
end
