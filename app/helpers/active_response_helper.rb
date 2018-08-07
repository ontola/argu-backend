# frozen_string_literal: true

module ActiveResponseHelper
  ACTION_MAP = {
    edit: :update,
    bin: :trash,
    unbin: :untrash,
    delete: :destroy,
    new: :create
  }.freeze

  def active_response_success_message
    if action_name == 'create' && current_resource.try(:argu_publication)&.publish_time_lapsed?
      t('type_publish_success', type: type_for(current_resource)).capitalize
    else
      t("type_#{action_name}_success", type: type_for(current_resource)).capitalize
    end
  end

  def create_meta
    data = []
    return data if index_collection.blank?
    meta_replace_collection_count(data, index_collection.unfiltered)
    authenticated_resource.applicable_filters.each do |key, value|
      meta_replace_collection_count(data, index_collection.unfiltered.new_child(filter: {key => value}))
    end
    data
  end

  def create_success_location
    redirect_location
  end

  def default_form_options(action)
    return super unless active_responder.is_a?(RDFResponder)
    super_opts = super
    action_resource = super_opts[:resource].try(:new_record?) ? index_collection : super_opts[:resource]
    form = super_opts[:view] == 'form' ? action_name : super_opts[:view]
    {
      action: action_resource.action(user_context, ACTION_MAP[form.to_sym] || form),
      include: ActiveResponse::Controller::RDF::Collections::ACTION_FORM_INCLUDES
    }
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
    data = []
    return data if index_collection.blank?
    meta_replace_collection_count(data, index_collection.unfiltered)
    authenticated_resource.applicable_filters.each do |key, value|
      meta_replace_collection_count(data, index_collection.unfiltered.new_child(filter: {key => value}))
    end
    data
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
    current_resource.persisted? ? current_resource.iri_path : current_resource.parent.iri_path
  end

  def redirect_message
    if action_name == 'create' && current_resource.try(:argu_publication)&.publish_time_lapsed?
      t('type_publish_success', type: type_for(current_resource)).capitalize
    else
      t("type_#{action_name}_success", type: type_for(current_resource)).capitalize
    end
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
    data.push [collection.iri, NS::AS[:pages], nil, NS::LL[:remove]]
    data.push [collection.iri, NS::AS[:totalItems], collection.total_count, NS::LL[:replace]]
  end
end