# Provides helpers for the translations and icons for when the {Forum} admin has changed the name of {Argument}, {Motion} or {Question}.
#
# All `foo_*` methods have a parameter `forum` which uses `@forum` if not passed.
module AlternativeNamesHelper

  #########################
  #        Motions        #
  #########################

  # Icon substring for motions
  def motion_icon(forum= nil)
    ((forum || @forum).motions_title_singular if alternative_motions?(forum)) || 'lightbulb-o'
  end

  # Singular translation for {Motion}
  def motion_type(forum= nil)
    ((forum || @forum).motions_title_singular if alternative_motions?(forum)) || I18n.t('motions.type')
  end

  # Plural translation for {Motion}
  def motions_type(forum= nil)
    ((forum || @forum).motions_title if alternative_motions?(forum)) || I18n.t('motions.plural')
  end

  # Does the {Forum} use alternative names for {Motion}?
  # :nodoc:
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

  # Icon substring for questions
  def question_icon(forum= nil)
    ((forum || @forum).questions_title_singular if alternative_questions?(forum)) || 'question'
  end

  # Singular translation for {Question}
  def question_type(forum= nil)
    ((forum || @forum).questions_title_singular if alternative_questions?(forum)) || I18n.t('questions.type')
  end

  # Plural translation for {Question}
  def questions_type(forum= nil)
    ((forum || @forum).questions_title if alternative_questions?(forum)) || I18n.t('questions.type')
  end

  # @private
  # Does the {Forum} use alternative names for {Question}?
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

  # Icon substring for arguments
  def argument_icon(forum= nil)
    ((forum || @forum).arguments_title_singular if alternative_arguments?(forum)) || 'argument'
  end

  # Singular translation for {Argument}
  def argument_type(forum= nil)
    ((forum || @forum).arguments_title_singular if alternative_arguments?(forum)) || I18n.t('arguments.type')
  end

  # Plural translation for {Argument}
  def arguments_type(forum= nil)
    ((forum || @forum).arguments_title if alternative_arguments?(forum)) || I18n.t('arguments.type')
  end

  # Does the {Forum} use alternative names for {Argument}?
  # :nodoc:
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

  # @return formtastic placeholder translation for an object
  def placeholder_for(item, field, type)
    I18n.t("formtastic.placeholders.#{item.class.name.downcase}.#{field}", type: type)
  end

  #@private
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
