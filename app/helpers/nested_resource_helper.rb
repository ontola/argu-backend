# Helper to determine the parent of the nested resource
# It is to be used with {AuthorizedController} inherited resource controllers
# @note Has been designed with a single parent resource in mind (route wise)
# @author Fletcher91 <thom@argu.co>
module NestedResourceHelper
  def current_resource_is_nested?(opts = request.path_parameters)
    parent_resource_key(opts).present?
  end

  # Finds the parent resource based on the URL's :foo_id param
  # If the controller is an {AuthorizedController}, it'll check for a persited {authenticated_resource!!}
  # @note This method knows {Shortnameable}
  # @param opts [Hash, nil] The path parameters, {ActionDispatch::Http::Parameters#path_parameters} is used when not given.
  # @return [Model] A resource model if found
  # @raise [ActiveRecord::RecordNotFound] {http://api.rubyonrails.org/classes/ActiveRecord/RecordNotFound.html Rails docs}
  # @see http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find ActiveRecord#find
  def get_parent_resource(opts = request.path_parameters, url_params = params)
    @parent_resource ||=
      if parent_resource_class(opts).try(:shortnameable?)
        parent_resource_class(opts).find_via_shortname! parent_id_from_params(url_params)
      else
        parent_resource_class(opts).find parent_id_from_params(url_params)
      end
  end

  # Determines the parent resource's class from the request
  # @return [Class] The parent resource class object
  # @see #parent_resource_klass
  def parent_resource_class(opts = request.path_parameters)
    parent_resource_klass(opts)
  end

  # Finds a 'resource key' from a params Hash
  # @example Find the parent resource key of a vote
  #   m_url = 'argu.co/m/8/v/pro'
  #   parent_resource_key(m_url) # => 'motion_id'
  def parent_resource_key(hash)
    hash.keys.find { |k| /_id/ =~ k }
  end

  # Constantizes a class string from the params hash
  # @note Safe to constantize since `path_parameters` uses the routes for naming.
  # @example Resource class for a vote request
  #   m_url = 'argu.co/m/8/v/pro'
  #   parent_resource_param # => Motion
  def parent_resource_klass(opts = request.path_parameters)
    parent_resource_type(opts).capitalize.constantize
  end

  # Extracts the parent resource param from the url to get to its value
  # @return [Symbol] The resource param
  # @see #parent_resource_key
  # @example Resource param for a vote request
  #   m_url = 'argu.co/m/8/v/pro'
  #   parent_resource_param # => :motion_id
  def parent_resource_param(opts = request.path_parameters)
    parent_resource_key(opts)
  end

  # Extracts the resource type string from a params hash
  # @return [String] The resource type string
  # @example Resource type for a vote
  #   m_url = 'argu.co/m/8/v/pro'
  #   parent_resource_type(m_url) # => 'motion'
  def parent_resource_type(opts = request.path_parameters)
    parent_resource_key(opts)[0..-4]
  end

  def resource_new_params
    if parent_resource_klass(request.path_parameters) == Forum
      super
    else
      super.merge({
        parent_resource_param => params[parent_resource_param]
      })
    end
  end

  # @see {get_parent_resource}
  # @return [Forum, nil] The tenant of the found resource by its parent
  def resource_tenant(opts = request.path_parameters, url_params = params)
    if current_resource_is_nested?(opts)
      parent = get_parent_resource(opts, url_params)
      parent.is_a?(Forum) ?
        parent :
        parent.forum
    end
  end

  private

  def parent_id_from_params(url_params)
    url_params[parent_resource_param(url_params)]
  end
end
