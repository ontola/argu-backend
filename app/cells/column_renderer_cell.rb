##
# Renders a collection of models in one or more columns
# @param #HashWithIndifferentAccess With column names as keys
# @param :header, title of the main header
# @param :buttons_url, string for the button beneath a column, gets the column key appended as parameter
# @param :collection_model, model of the collection, used for translations @todo: fix this hack so this param is obsolete
class ColumnRendererCell < Cell::ViewModel
  extend ViewModel
  builds do |model, options|
    if model.is_a?(Motion)
      MotionCell
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

  #
  def header
    content_tag :header do
      content_tag :h1, options[:header]
    end
  end

  # This generates the translations for the header text, e.g. "arguments.header.pro"
  def header_text(key)
    I18n.t("#{options[:collection_model].to_s.pluralize.downcase}.header.#{key}")
  end

  # Keys of the model hash
  def keys
    model.keys
  end

  def show_new_buttons
    if options[:buttons_url].present?
      raw cell(:button, options)
      #TODO change color for argument sides (pro vs con) and type (argument / question / motion)
    end
  end

  def title
    model.title
  end

end