# frozen_string_literal: true

module ActiveResponseHelper
  private

  def active_response_success_message # rubocop:disable Metrics/AbcSize
    if current_resource.try(:is_publishable?) && (action_name == 'create' || resource_was_published?)
      if current_resource.try(:argu_publication)&.publish_time_lapsed?
        t('type_publish_success', type: type_for(current_resource).capitalize)
      else
        t('type_draft_success', type: type_for(current_resource).capitalize)
      end
    else
      t("type_#{action_name}_success", type: type_for(current_resource).capitalize)
    end
  end

  def create_success_location
    redirect_location
  end

  def default_form_view(action)
    if lookup_context.exists?("#{controller_path}/#{action}")
      action
    elsif lookup_context.exists?("application/#{action}")
      "application/#{action}"
    else
      'form'
    end
  end

  def default_form_view_locals(_action)
    {
      model_name => current_resource,
      resource: current_resource
    }
  end

  def destroy_meta
    resource_removed_delta(current_resource)
  end

  def destroy_success_location
    redirect_location
  end

  def index_association
    @index_association ||= policy_scope(super)
  end

  def index_success_options_json_api
    index_success_options_rdf
  end

  def index_success_options_rdf
    skip_verify_policy_scoped(true) if index_collection_or_view.present?
    super
  end

  def redirect_location
    return current_resource.iri if current_resource.persisted? || !current_resource.respond_to?(:parent)
    current_resource.parent.iri
  end

  def redirect_message
    if action_name == 'create' && current_resource.try(:argu_publication)&.publish_time_lapsed?
      t('type_publish_success', type: type_for(current_resource).capitalize)
    else
      t("type_#{action_name}_success", type: type_for(current_resource).capitalize)
    end
  end

  def resource_was_published?
    current_resource.try(:argu_publication)&.previous_changes&.key?(:published_at)
  end

  def respond_with(*resources, &_block)
    return super if format_html?
    opts = resources.size == 1 ? {} : resources.extract_options!
    resource = resources.first
    active_response_block do
      if active_response_type == :html
        super
      elsif respond_with_422?(resources)
        respond_with_block_failure(resource, opts)
      else
        respond_with_block_success(resource, opts)
      end
    end
  end

  def respond_with_block_failure(resource, opts)
    respond_with_failure!
    respond_with_invalid_resource(respond_with_block_options(resource, opts))
  end

  def respond_with_block_success(resource, opts)
    respond_with_success!
    response_options = respond_with_block_options(resource, opts)
    case action_name
    when 'create'
      respond_with_new_resource(response_options)
    when 'destroy'
      respond_with_destroyed(response_options)
    when 'update'
      respond_with_updated_resource(response_options)
    when 'show'
      respond_with_resource(response_options)
    else
      head(200)
    end
  end

  def respond_with_block_options(resource, opts)
    active_response_options
      .merge(opts)
      .merge(resource: resource.presence, notice: flash[:notice] || flash[:success])
  end

  def show_view_locals
    {
      model_name => current_resource,
      resource: current_resource
    }
  end

  def update_success_location
    redirect_location
  end

  def meta_replace_collection_count(data, collection)
    collection.clear_total_count
    data.push [collection.iri, NS::ONTOLA[:pages], nil, NS::LL[:remove]]
    data.push [collection.iri, NS::AS[:totalItems], collection.total_count, delta_iri(:replace)]
  end
end
