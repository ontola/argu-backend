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

  def keys
    model.keys
  end

  def show_new_buttons
    if options[:buttons_url].present?
      content_tag :div, class: 'center' do
        link_to I18n.t("#{options[:buttons_model].name.pluralize.downcase}.new_btn"), options[:buttons_url], class: 'btn btn-white'
      end
    end
  end

  def title
    model.title
  end

end