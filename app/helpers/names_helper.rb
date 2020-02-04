# frozen_string_literal: true

# Provides helpers for the translations and icons.
module NamesHelper
  extend ActiveSupport::Concern

  included do
    if respond_to?(:hide_action)
      hide_action :argument_icon
      hide_action :argument_type
      hide_action :arguments_type
      hide_action :blog_post_icon
      hide_action :motion_icon
      hide_action :motion_type
      hide_action :motions_type
      hide_action :questions_type
      hide_action :question_icon
      hide_action :question_type
      hide_action :placeholder_for
    end
  end

  #########################
  #       Arguments       #
  #########################

  # Icon substring for arguments
  def argument_icon
    'argument'
  end

  # Singular translation for {Argument}
  def argument_type
    I18n.t('arguments.type')
  end

  # Plural translation for {Argument}
  def arguments_type
    I18n.t('arguments.plural')
  end

  #########################
  #       Blog Post       #
  #########################

  # Icon substring for blog posts
  def blog_post_icon
    'bullhorn'
  end

  # Singular translation for {BlogPost}
  def blog_post_type
    I18n.t('blog_posts.type')
  end

  #########################
  #       Decision        #
  #########################

  # Icon substring for decision
  def decision_icon(naming_object = nil)
    case naming_object.state
    when 'approved'
      'check-square-o'
    when 'rejected'
      'times-circle'
    when 'forwarded'
      'share'
    end
  end

  #########################
  #        Motions        #
  #########################

  # Icon substring for motions
  def motion_icon
    'lightbulb-o'
  end

  # Singular translation for {Motion}
  def motion_type
    I18n.t('motions.type')
  end

  # Plural translation for {Motion}
  def motions_type
    I18n.t('motions.plural')
  end

  #########################
  #       Questions       #
  #########################

  # Icon substring for questions
  def question_icon
    'question'
  end

  # Singular translation for {Question}
  def question_type
    I18n.t('questions.type')
  end

  # Plural translation for {Question}
  def questions_type
    I18n.t('questions.plural')
  end

  #########################
  #         Other         #
  #########################

  # @return formtastic placeholder translation for an object
  def placeholder_for(item, field, type)
    I18n.t("formtastic.placeholders.#{item.class.name.underscore}.#{field}", type: type)
  end

  private

  # @private
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  def icon_for(item)
    if [item.class, item].include?(BlogPost)
      blog_post_icon
    elsif item.class == Decision
      decision_icon(item)
    elsif item == Decision
      'legal'
    elsif [item.class, item].include?(Motion)
      motion_icon
    elsif [item.class, item].include?(Question)
      question_icon
    elsif [item.class, item].include?(Argument)
      argument_icon
    elsif [item.class, item].include?(ProArgument)
      'plus'
    elsif [item.class, item].include?(ConArgument)
      'minus'
    elsif [item.class, item].include?(Comment)
      'comment'
    elsif [item.class, item].include?(Topic)
      'comments'
    elsif [item.class, item].include?(ProOpinion)
      'thumbs-up'
    elsif [item.class, item].include?(ConOpinion)
      'thumbs-down'
    elsif [item.class, item].include?(NeutralOpinion)
      'pause'
    elsif [item.class, item].include?(MediaObject)
      'file'
    elsif [item.class, item].include?(Phase)
      'calendar-o'
    elsif [item.class, item].include?(Project)
      'rocket'
    elsif [item.class, item].include?(Survey)
      'list-ul'
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

  # @private
  def type_for(item)
    I18n.t("#{item.model_name.collection}.type")
  end
end
