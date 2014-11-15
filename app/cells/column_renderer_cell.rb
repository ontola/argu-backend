class ColumnRendererCell < Cell::ViewModel
  extend ViewModel
  builds do |model, options|
    if model.is_a?(Statement)
      StatementCell
    elsif model.is_a?(Argument)
      ArgumentCell
    elsif model.is_a?(Vote)
      VoteCell
    elsif model.is_a?(Opinion)
      OpinionCell
    end
  end

  def show
    render
  end

  private

  def header
    options[:header]
  end

  # This generates the translations for the header text, e.g. "arguments.header.pro"
  def header_text(key)
    I18n.t("#{options[:collection_model].to_s.pluralize.downcase}.header.#{key}")
  end

  def keys
    model.keys
  end

  def show_new_buttons
    if options[:buttons_url].present?
      raw cell(:button, options)
      #TODO change color for argument sides (pro vs con) and type (argument / question / statement)
    end
  end

  def title
    model.title
  end

end