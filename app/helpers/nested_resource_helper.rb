# Helper to determine the parent of the nested resource
# It is to be used with {AuthenticatedController} inherited resource controllers
# @note Has been designed with a single parent resource in mind (route wise)
# @author Fletcher91 <thom@argu.co>
module NestedResourceHelper

  # Finds the parent resource based on the URL's :foo_id param
  # @return [Model] A resource model if found
  # @raise [ActiveRecord::RecordNotFound] {http://api.rubyonrails.org/classes/ActiveRecord/RecordNotFound.html Rails docs}
  # @see http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find ActiveRecord#find
  def get_parent_resource
    parent_resource_class.find params[parent_resource_param]
  end

  # Determines the parent resource's class from the request
  # @return [Class] The parent resource class object
  # @see #parent_resource_klass
  def parent_resource_class
    parent_resource_klass(request.path_parameters)
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
  def parent_resource_klass(opts = nil)
    parent_resource_type(opts).capitalize.constantize
  end


  # Extracts the parent resource param from the url to get to its value
  # @return [Symbol] The resource param
  # @see #parent_resource_key
  # @example Resource param for a vote request
  #   m_url = 'argu.co/m/8/v/pro'
  #   parent_resource_param # => :motion_id
  def parent_resource_param
    parent_resource_key(request.path_parameters)
  end

  # Extracts the resource type string from a params hash
  # @return [String] The resource type string
  # @example Resource type for a vote
  #   m_url = 'argu.co/m/8/v/pro'
  #   parent_resource_type(m_url) # => 'motion'
  def parent_resource_type(opts = nil)
    parent_resource_key(opts)[0..-4]
  end

end
