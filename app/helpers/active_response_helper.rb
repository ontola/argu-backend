# frozen_string_literal: true

module ActiveResponseHelper
  private

  def active_response_failure_message
    I18n.t("type_#{action_name}_failure", type: current_resource.class.label.downcase)
  end

  def active_response_success_message # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
    return send("#{action_name}_success_message") if respond_to?("#{action_name}_success_message", true)

    if current_resource.try(:is_publishable?) && (action_name == 'create' || resource_was_published?)
      if current_resource.try(:argu_publication)&.publish_time_lapsed?
        I18n.t('type_publish_success', type: current_resource.class.label.capitalize)
      else
        I18n.t('type_draft_success', type: current_resource.class.label.capitalize)
      end
    else
      I18n.t("type_#{action_name}_success", type: current_resource.class.label.capitalize)
    end
  end

  def create_success_location
    redirect_location
  end

  def destroy_meta
    resource_removed_delta(current_resource)
  end

  def destroy_success_location
    redirect_location
  end

  def index_success_options_json_api
    index_success_options_rdf
  end

  def index_success_options_rdf
    skip_verify_policy_scoped(true)
    super
  end

  def redirect_location
    return current_resource.iri if current_resource.persisted?
    return root_path unless current_resource.respond_to?(:parent)

    current_resource.parent.iri
  end

  def redirect_message # rubocop:disable Metrics/AbcSize
    if action_name == 'create' && current_resource.try(:argu_publication)&.publish_time_lapsed?
      I18n.t('type_publish_success', type: current_resource.class.label.capitalize)
    else
      I18n.t("type_#{action_name}_success", type: current_resource.class.label.capitalize)
    end
  end

  def resource_was_published?
    current_resource.try(:argu_publication)&.previous_changes&.key?(:published_at)
  end

  def respond_with(*resources, &_block)
    opts = resources.size == 1 ? {} : resources.extract_options!
    resource = resources.first
    active_response_block do
      if respond_with_422?(resources)
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

  def respond_with_block_success(resource, opts) # rubocop:disable Metrics/MethodLength
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
      .merge(resource: resource.presence)
  end

  def show_failure_options
    {}
  end

  def update_success_location
    redirect_location
  end
end
