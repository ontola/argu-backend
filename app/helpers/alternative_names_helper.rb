# Provides helpers for the translations and icons for when the {Forum} admin has changed the name of {Argument}, {Motion} or {Question}.
#
# All `foo_*` methods have a parameter `forum` which uses `naming_context` if not passed.
module AlternativeNamesHelper
  extend ActiveSupport::Concern

  included do
    if respond_to?(:helper_method)
      helper_method :naming_context
    end
    if respond_to?(:hide_action)
      hide_action :naming_context
      hide_action :motion_icon
      hide_action :motion_type
      hide_action :motions_type
      hide_action :alternative_motions?
      hide_action :question_icon
      hide_action :question_type
      hide_action :questions_type
      hide_action :alternative_questions?
      hide_action :argument_icon
      hide_action :argument_type
      hide_action :arguments_type
      hide_action :alternative_arguments?
      hide_action :placeholder_for
    end
  end

  #########################
  #       Blog Post       #
  #########################

  # Icon substring for blog posts
  def blog_post_icon(naming_object= nil)
    'bullhorn'
  end

  #########################
  #        Motions        #
  #########################

  # Icon substring for motions
  def motion_icon(naming_object= nil)
    'lightbulb-o'
  end

  # Singular translation for {Motion}
  def motion_type(naming_object= nil)
    alternative_motions?(naming_object) ?
      (naming_object || naming_context).motions_title_singular :
      I18n.t('motions.type')
  end

  # Plural translation for {Motion}
  def motions_type(naming_object= nil)
      alternative_motions?(naming_object) ?
        (naming_object || naming_context).motions_title :
        I18n.t('motions.plural')
  end

  # Does the {Forum} use alternative names for {Motion}?
  # :nodoc:
  def alternative_motions?(naming_object= nil)
    if naming_object == nil
      @alternative_motions ||= (naming_context.uses_alternative_names &&
          naming_context.motions_title_singular.present? &&
          naming_context.motions_title.present?)
    else
      naming_object.try(:uses_alternative_names) &&
          naming_object.try(:motions_title_singular).present? &&
          naming_object.try(:motions_title).present?
    end
  end

  #########################
  #       Questions       #
  #########################

  # Icon substring for questions
  def question_icon(naming_object= nil)
    'question'
  end

  # Singular translation for {Question}
  def question_type(naming_object= nil)
    alternative_questions?(naming_object) ?
      (naming_object || naming_context).questions_title_singular :
      I18n.t('questions.type')
  end

  # Plural translation for {Question}
  def questions_type(naming_object= nil)
    (naming_object || naming_context).questions_title ?
      alternative_questions?(naming_object) :
      I18n.t('questions.type')
  end

  # @private
  # Does the {Forum} use alternative names for {Question}?
  def alternative_questions?(naming_object= nil)
    if naming_object == nil || !naming_object.is_a?(Forum)
      @alternative_questions ||= naming_context.uses_alternative_names &&
          naming_context.questions_title_singular.present? &&
          naming_context.questions_title.present?
    else
      naming_object.try(:uses_alternative_names) &&
          naming_object.try(:questions_title_singular).present? &&
          naming_object.try(:questions_title).present?
    end
  end

  #########################
  #       Arguments       #
  #########################

  # Icon substring for arguments
  def argument_icon(naming_object= nil)
    (naming_object || naming_context).arguments_title_singular ?
      alternative_arguments?(naming_object) :
      'argument'
  end

  # Singular translation for {Argument}
  def argument_type(naming_object= nil)
    alternative_arguments?(naming_object) ?
      (naming_object || naming_context).arguments_title_singular :
      I18n.t('arguments.type')
  end

  # Plural translation for {Argument}
  def arguments_type(naming_object= nil)
    (naming_object || naming_context).arguments_title ?
      alternative_arguments?(naming_object) :
      I18n.t('arguments.type')
  end

  # Does the {Forum} use alternative names for {Argument}?
  # :nodoc:
  def alternative_arguments?(naming_object= nil)
    if naming_object == nil || !naming_object.is_a?(Forum)
      @alternative_arguments ||= naming_context.uses_alternative_names &&
          naming_context.arguments_title_singular.present? &&
          naming_context.arguments_title.present?
    else
      naming_object.try(:uses_alternative_names) &&
          naming_object.try(:arguments_title_singular).present? &&
          naming_object.try(:arguments_title).present?
    end
  end

  #########################
  #         Other         #
  #########################

  # Used to declare the default naming context to check for {uses_alternative_names}
  # @note This must be overridden in the implementing object.
  def naming_context
    raise 'Naming context not defined'
  end

  # @return formtastic placeholder translation for an object
  def placeholder_for(item, field, type)
    I18n.t("formtastic.placeholders.#{item.class.name.downcase}.#{field}", type: type)
  end

  private

  #@private
  def type_for(item, plural=false)
    if item.class == Motion
      motion_type(item.forum)
    elsif item.class == Question
      question_type(item.forum)
    elsif item.class == Argument
      argument_type(item.forum)
    elsif item.class == Comment
      I18n.t('comments.type')
    end
  end
end
