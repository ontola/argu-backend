class MotionCell < Cell::ViewModel
  def show
    render
  end

  private
  property :title, :argument_pro_count, :argument_con_count, :is_main_motion?

  def pro_con_count_label
    I18n.t("statements.preview.pro", count: argument_pro_count) + ', ' + I18n.t("statements.preview.con", count: argument_con_count)
  end

  def supped_content
    model.supped_content.html_safe
  end

end