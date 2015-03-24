module AlternativeNamesHelper

  #########################
  #        Motions        #
  #########################
  def motion_icon(forum= nil)
    ((forum || @forum).motions_title_singular if alternative_motions?(forum)) || 'lightbulb-o'
  end

  def motion_type(forum= nil)
    ((forum || @forum).motions_title_singular if alternative_motions?(forum)) || I18n.t('motions.type')
  end

  def motions_type(forum= nil)
    ((forum || @forum).motions_title if alternative_motions?(forum)) || I18n.t('motions.plural')
  end

  def alternative_motions?(forum= nil)
    if forum == nil
      @alternative_motions ||= @forum.uses_alternative_names &&
          @forum.motions_title_singular.present? &&
          @forum.motions_title.present?
    else
      forum.uses_alternative_names &&
          forum.motions_title_singular.present? &&
          forum.motions_title.present?
    end
  end

  #########################
  #       Questions       #
  #########################
  def question_icon(forum= nil)
    ((forum || @forum).questions_title_singular if alternative_questions?(forum)) || 'question'
  end

  def question_type(forum= nil)
    ((forum || @forum).questions_title_singular if alternative_questions?(forum)) || I18n.t('questions.type')
  end

  def questions_type(forum= nil)
    ((forum || @forum).questions_title if alternative_questions?(forum)) || I18n.t('questions.type')
  end

  def alternative_questions?(forum= nil)
    if forum == nil
      @alternative_questions ||= @forum.uses_alternative_names &&
          @forum.questions_title_singular.present? &&
          @forum.questions_title.present?
    else
      forum.uses_alternative_names &&
          forum.questions_title_singular.present? &&
          forum.questions_title.present?
    end
  end

  #########################
  #       Arguments       #
  #########################
  def argument_icon(forum= nil)
    ((forum || @forum).arguments_title_singular if alternative_arguments?(forum)) || 'argument'
  end

  def argument_type(forum= nil)
    ((forum || @forum).arguments_title_singular if alternative_arguments?(forum)) || I18n.t('arguments.type')
  end

  def arguments_type(forum= nil)
    ((forum || @forum).arguments_title if alternative_arguments?(forum)) || I18n.t('arguments.type')
  end

  def alternative_arguments?(forum= nil)
    if forum == nil
      @alternative_arguments ||= @forum.uses_alternative_names &&
          @forum.arguments_title_singular.present? &&
          @forum.arguments_title.present?
    else
      forum.uses_alternative_names &&
          forum.arguments_title_singular.present? &&
          forum.arguments_title.present?
    end
  end


  #########################
  #         Other         #
  #########################
  def placeholder_for(item, field, type)
    I18n.t("formtastic.placeholders.#{item.class.name.downcase}.#{field}", type: type)
  end

  def type_for(item, plural=false)
    if item.class == Motion
      motion_type(item.forum)
    elsif item.class == Question
      question_type(item.forum)
    elsif item.class == Argument
      argument_type(item.forum)
    end
  end
end
