module ContextHelper
  def to_parent
    render partial: 'contextualize/to_parent' if current_context.has_parent?
  end

  def contextual_link_to(name = nil, options = nil, html_options = nil, &block)
    if block_given?
      name = merge_query_parameter(name, current_context.to_query) if name.class == String
    else
      options = merge_query_parameter(options, current_context.to_query) if options.class == String
    end
    link_to name, options, html_options, &block
  end

end