# Provides helpers for the translations and icons for when the {Forum} admin
# has changed the name of {Argument}, {Motion} or {Question}.
#
# All `foo_*` methods have a parameter `forum` which uses `naming_context` if not passed.
module AlternativeNamesHelper
  extend ActiveSupport::Concern

  included do
    helper_method :naming_context if respond_to?(:helper_method)

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
  def blog_post_icon(naming_object = nil)
    'bullhorn'
  end

  #########################
  #        Motions        #
  #########################

  # Icon substring for motions
  def motion_icon(naming_object = nil)
    'lightbulb-o'
  end

  # Singular translation for {Motion}
  def motion_type(naming_object = nil)
    if alternative_motions?(naming_object)
      naming_context(naming_object).motions_title_singular
    else
      I18n.t('motions.type')
    end
  end

  # Plural translation for {Motion}
  def motions_type(naming_object = nil)
    if alternative_motions?(naming_object)
      naming_context(naming_object).motions_title
    else
      I18n.t('motions.plural')
    end
  end

  # Does the {Forum} use alternative names for {Motion}?
  # :nodoc:
  def alternative_motions?(naming_object = nil)
    return false if naming_context(naming_object).nil? ||
        !naming_context(naming_object).respond_to?(:motions_title)
    (naming_context(naming_object).uses_alternative_names &&
      naming_context(naming_object).motions_title_singular.present? &&
      naming_context(naming_object).motions_title.present?)
  end

  #########################
  #       Questions       #
  #########################

  # Icon substring for questions
  def question_icon(naming_object = nil)
    'question'
  end

  # Singular translation for {Question}
  def question_type(naming_object = nil)
    if alternative_questions?(naming_object)
      naming_context(naming_object).questions_title_singular
    else
      I18n.t('questions.type')
    end
  end

  # Plural translation for {Question}
  def questions_type(naming_object = nil)
    if alternative_questions?(naming_object)
      naming_context(naming_object).questions_title
    else
      I18n.t('questions.plural')
    end
  end

  # @private
  # Does the {Forum} use alternative names for {Question}?
  def alternative_questions?(naming_object = nil)
    return false if naming_context(naming_object).nil? ||
        !naming_context(naming_object).respond_to?(:questions_title)
    naming_context(naming_object).uses_alternative_names &&
      naming_context(naming_object).questions_title_singular.present? &&
      naming_context(naming_object).questions_title.present?
  end

  #########################
  #       Arguments       #
  #########################

  # Icon substring for arguments
  def argument_icon(naming_object = nil)
    'argument'
  end

  # Singular translation for {Argument}
  def argument_type(naming_object = nil)
    if alternative_arguments?(naming_object)
      naming_context(naming_object).arguments_title_singular
    else
      I18n.t('arguments.type')
    end
  end

  # Plural translation for {Argument}
  def arguments_type(naming_object = nil)
    if alternative_arguments?(naming_object)
      naming_context(naming_object).arguments_title
    else
      I18n.t('arguments.plural')
    end
  end

  # Does the {Forum} use alternative names for {Argument}?
  # :nodoc:
  def alternative_arguments?(naming_object = nil)
    return false if naming_context(naming_object).nil? ||
        !naming_context(naming_object).respond_to?(:arguments_title)
    naming_context(naming_object).uses_alternative_names &&
      naming_context(naming_object).arguments_title_singular.present? &&
      naming_context(naming_object).arguments_title.present?
  end

  #########################
  #        Project        #
  #########################

  # Icon substring for project
  def project_icon(naming_object = nil)
    'rocket'
  end

  # Singular translation for {Project}
  def project_type(naming_object = nil)
    I18n.t('projects.type')
  end

  #########################
  #         Other         #
  #########################

  # Used to declare the default naming context to check for {uses_alternative_names}
  def naming_context(naming_object = nil)
    (naming_object ||
      (authenticated_resource if respond_to?(:authenticated_resource, true)) ||
      (resource_by_id if respond_to?(:resource_by_id, true)))
      &.naming_context
  end

  # @return formtastic placeholder translation for an object
  def placeholder_for(item, field, type)
    I18n.t("formtastic.placeholders.#{item.class.name.downcase}.#{field}", type: type)
  end

  private

  # @private
  def type_for(item, plural = false)
    if item.class == Motion
      motion_type(item.forum)
    elsif item.class == Question
      question_type(item.forum)
    elsif item.class == Argument
      argument_type(item.forum)
    elsif item.class == Comment
      I18n.t('comments.type')
    elsif item.class == Forum
      I18n.t('forums.type')
    elsif item.class == Project
      I18n.t('projects.type')
    end
  end
end
