##
# Base class for contextualisation data, currently only does parenting.
#
# todo: lazy load items when parsed from a string (every item currently creates a db request)
class Context
  using StringExtensions
  extend ArguExtensions::Context # WHY DOES THE SEND :EXTEND NOT WORK
  #include Rails.application.routes.url_helpers
  include ApplicationHelper # For merge_query_parameters
  @parent_context

  # @!attribute model
  # @return [ActiveRecord::Collection] The current model
  attr_accessor :model

  def initialize(model = nil, context=nil)
    self.model = (model.class == String) ? parse_from_string(model) : model
    @parent_context = case context
      when Context then context
      when String then Context.new parse_from_string(context)
      else nil
    end
  end

  # Generates a URL to the current object with it's parents as a query string
  def contextized_url
    merge_query_parameter(url, (parent.to_query if parent.present?))
  end

  def has_parent?
    self.parent.present?
  end

  # Whether the parent's contexts' model is present
  def parent_initialized?
    @parent_context.present?
  end

  # Returns the model or the first if {Context#model} is a collection
  def single_model
    @model.try(:length) ? @model.first : @model
  end

  # Setter (using an instance value)
  def model=(value)
    @model = value
  end

  # @!attribute parent
  # @return [String] Parent {Context} object of the current {Context}
  def parent
    @parent_context || model && model.try(:get_parent)
  end

  def self.parse_from_uri(value, model=nil, &block)
    context_string = Hash[URI.decode_www_form(URI.parse(value.to_s).query || '')]['context']
    if context_string
      Context.parse_from_context_string context_string, model, &block
    elsif model.present? && model.try(:get_parent)
      Context.new model, model.get_parent
    else
      Context.new model.present? ? model : nil
    end
  end

  # Parses a {Context} object chain from a {Context}-string
  def self.parse_from_context_string(value, current=nil, &block)
    components = value.split('*').map { |c| c.split(/ |\+/) }.map! { |c| c[0].capitalize.constantize_with_care([Forum, Question, Motion, Argument, Comment]).find c[1] }

    yield components if block_given?

    (components << current).compact!
    context = Context.new(components.shift)
    components.each { context.push(components.shift) }
    context
  end

  # Takes the topmost item off the stack and returns the item
  # Note to reader: take a CS course
  # @return Topmost item that was taken off the stack
  def pop
    _current_model = self.model
    self.model = @parent_context.model
    _current_model
  end

  # Checks whether a model is loaded
  def present?
    model.present?
  end

  # Adds a model to the top of the stack
  def push(p_model)
    if p_model.present?
      @parent_context = Context.new(model, @parent_context) if model.present?
      self.model = p_model
      self
    end
  end

  # Recurse up the tree to the topmost parent {Context}
  def root_parent
    if self.parent.present?
      self.parent.root_parent
    else
      self
    end
  end

  # Generates a HTTP query compatible string to parse back the breadcrumb stack
  def to_query
    context = recurse_to_s
    context.present? ? "context=#{recurse_to_s}" : ''
  end

  # Converts the #Context stack to a #Hash
  def to_hash(value = {})
    value[:model] = model
    value[:url] = url
    value[:parent_context] = @parent_context.to_hash if @parent_context.present?
    value
  end

  # @!attribute url
  # @return [String] A URL to the current model
  def url
    Rails.application.routes.url_helpers.url_for(controller: single_model.class.name.downcase.pluralize,
                                                 action: 'show',
                                                 id: single_model.id,
                                                 only_path: true) if single_model
  end

  protected
  def parse_from_string(value)
    begin
      split = value.split(/ |\+/)
      split[0].capitalize.constantize.find split[1]
    rescue NameError # Someone messed with the URL
      nil
    end
  end

  # Recurses down the line of @parent_contexts
  def recurse_to_s
    model_string = single_model.present? ? "#{single_model.class.name}+#{single_model.id.to_s}" : ''
    if @parent_context
      parent_string = @parent_context.recurse_to_s
      parent_string = "*#{parent_string}" if parent_string.present?
    end
    "#{model_string}#{parent_string}"
  end

end
