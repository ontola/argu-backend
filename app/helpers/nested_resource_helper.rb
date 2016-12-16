# frozen_string_literal: true
# Helper to determine the parent of the nested resource
# It is to be used with {AuthorizedController} inherited resource controllers
# @note Has been designed with a single parent resource in mind (route wise)
# @author Fletcher91 <thom@argu.co>
module NestedResourceHelper
  ARGU_URI_MATCH = /(#{Regexp.quote(Rails.configuration.host)}|argu.co)/

  def current_resource_is_nested?(opts = params)
    parent_id_from_params(opts).present?
  end

  # Finds the parent edge based on the URL's :foo_id param
  # @note This method knows {Shortnameable}
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [Edge] An Edge if found
  # @raise [ActiveRecord::RecordNotFound] {http://api.rubyonrails.org/classes/ActiveRecord/RecordNotFound.html Rails
  #   docs}
  # @see http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find ActiveRecord#find
  def get_parent_edge(opts = params)
    @parent_resource ||=
      if parent_resource_class(opts).try(:shortnameable?)
        parent_resource_class(opts).find_via_shortname!(parent_id_from_params(opts)).edge
      else
        Edge.find_by!(owner_type: parent_resource_type(opts).camelcase, id: parent_id_from_params(opts))
      end
  end

  # Finds the parent resource based on the URL's :foo_id param
  # If the controller is an {AuthorizedController}, it'll check for a persited {authenticated_resource!!}
  # @note This method knows {Shortnameable}
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [ApplicationRecord] A resource model if found
  # @raise [ActiveRecord::RecordNotFound] {http://api.rubyonrails.org/classes/ActiveRecord/RecordNotFound.html Rails
  #   docs}
  # @see http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find ActiveRecord#find
  def get_parent_resource(opts = params)
    @parent_resource ||=
      if parent_resource_class(opts).try(:shortnameable?)
        parent_resource_class(opts).find_via_shortname! parent_id_from_params(opts)
      else
        parent_resource_class(opts).find parent_id_from_params(opts)
      end
  end

  # Extracts the resource id from a params hash
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [String] The resource id
  # @example Resource id from parent iri
  #   params = {parent: 'https://argu.co/m/1'}
  #   parent_id_from_params # => '1'
  # @example Resource class from motion_id
  #   params = {motion_id: 1}
  #   parent_id_from_params # => '1'
  def parent_id_from_params(opts = params)
    if deserialized_params[:parent].present?
      id_and_type_from_iri(deserialized_params[:parent])[:id]
    else
      opts[parent_resource_param(opts)]
    end
  end

  # Determines the parent resource's class from the request
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [ApplicationRecord] The parent resource class object
  # @see #parent_resource_klass
  def parent_resource_class(opts = params)
    parent_resource_klass(opts)
  end

  # Finds a 'resource key' from a params Hash
  # @example Resource key from motion_id
  #   params = {motion_id: 1}
  #   parent_resource_key # => :motion_id
  def parent_resource_key(hash)
    hash.keys.find { |k| /_id/ =~ k }
  end

  # Constantizes a class string from the params hash
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [ApplicationRecord] The parent resource class object
  # @note Whether the given parent is allowed for the requested resource is not validated here.
  def parent_resource_klass(opts = params)
    parent_resource_type(opts).classify.constantize
  end

  # Extracts the parent resource param from the url to get to its value
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [Symbol] The resource param
  # @see #parent_resource_key
  def parent_resource_param(opts = params)
    parent_resource_key(opts)
  end

  # Extracts the resource type string from a params hash
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [String] The resource type string
  # @example Resource type from parent iri
  #   params = {parent: 'https://argu.co/m/1'}
  #   parent_resource_type # => 'motion'
  # @example Resource type from motion_id
  #   params = {motion_id: 1}
  #   parent_resource_type # => 'motion'
  def parent_resource_type(opts = params)
    if deserialized_params[:parent].present?
      id_and_type_from_iri(deserialized_params[:parent])[:type]
    else
      parent_resource_key(opts)[0..-4]
    end
  end

  # @see {get_parent_resource}
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [Forum, nil] The tenant of the found resource by its parent
  def resource_tenant(opts = params)
    return unless current_resource_is_nested?(opts)
    parent = get_parent_resource(opts)
    case parent
    when Forum
      parent
    else
      parent.try(:forum)
    end
  end

  # Converts an Argu URI into a hash containing the type and id of the resource
  # @return [Hash] The id and type of the resource, or nil if the IRI is not found
  # @example Valid IRI
  #   iri = 'https://argu.co/m/1'
  #   id_and_type_from_iri # => {type: 'motions', id: '1'}
  # @example Invalid IRI
  #   iri = 'https://example.com/m/1'
  #   id_and_type_from_iri # => {}
  # @example Nil IRI
  #   iri = nil
  #   id_and_type_from_iri # => {}
  def id_and_type_from_iri(iri)
    match = iri =~ ARGU_URI_MATCH unless iri.nil?
    return {} if iri.nil? || match.nil? || match <= 0
    parent = Rails.application.routes.recognize_path(iri)
    return {} unless parent[:action] == 'show' && parent[:id].present? && parent[:controller].present?
    {id: parent[:id], type: parent[:controller].singularize}
  rescue ActionController::RoutingError
    {}
  end
end
