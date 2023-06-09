# frozen_string_literal: true

module Argu
  class ActivityString
    include ActionView::Helpers
    include ActionDispatch::Routing
    include Rails.application.routes.url_helpers

    # Generates an activity string for an activity in the sense of: 'Foo responded to your Bar'
    # @param [string] activity The Activity to generate the activity_string for
    # @param [User] user The User to generate the activity_string for
    # @param [symbol] render Set to `template` to embed handlebars-like template variables.
    # Defaults to `display_name` which interpolates the display name.
    def initialize(activity, user, render: :display_name)
      @activity = activity
      @user = user
      @render = render.to_sym
    end

    def to_s # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      default = I18n.t(translation_key('activities.default'),
                       owner: owner_string,
                       type: type_string,
                       subject: subject_string,
                       parent: parent_string,
                       default: nil)
      # rubocop:disable Rails/OutputSafety
      I18n.t(translation_key("activities.#{@activity.trackable_type.tableize}"),
             owner: owner_string,
             type: type_string,
             subject: subject_string,
             parent: parent_string,
             side: side_string,
             group_singular: group_singular_string,
             default: default).html_safe
      # rubocop:enable Rails/OutputSafety
    end

    private

    # @return [String, nil] Singlar name of activity.trackable.group, as text
    def group_singular_string
      return nil unless @activity.trackable.try(:group)

      @activity.trackable.group.name_singular
    end

    # @return [String] Display name of activity.owner, as link or bold text
    def owner_string
      string = @activity.owner.display_name
      if @render == :template && @activity.owner_id.positive?
        '{{https://www.w3.org/ns/activitystreams#actor}}'
      else
        string.to_s
      end
    end

    # @return [String, nil] Display name of activity.trackable.parent, as link or bold text
    def parent_string
      recipient = @activity.recipient_type == 'VoteEvent' ? @activity.recipient&.voteable : @activity.recipient
      return @activity.audit_data.try(:[], 'recipient_name') if recipient.nil?

      if @render == :template
        '{{https://www.w3.org/ns/activitystreams#target}}'
      else
        recipient.display_name
      end
    end

    # @return [String, nil] Translation of pro, neutral or con
    def side_string
      return nil unless @activity&.trackable&.is_a?(Vote) || @activity&.trackable&.is_a?(Argument)

      I18n.t("activities.#{@activity.trackable_type.tableize}.#{@activity.trackable.option}",
             default: @activity.trackable.option)
    end

    def subject_display_name
      if @activity.object == 'comment'
        @activity.trackable_class.label.downcase
      elsif @activity.trackable.present?
        @activity.trackable.try(:display_name)
      else
        @activity.audit_data.try(:[], 'trackable_name')
      end
    end

    # @return [String] Display name of activity.trackable, as link or bold text
    def subject_string
      if @render == :template && @activity.trackable.present?
        '{{https://www.w3.org/ns/activitystreams#object}}'
      else
        subject_display_name.to_s
      end
    end

    def translation_key(base_key)
      [base_key, @activity.action].join('.')
    end

    # @return [String] Type name of activity.trackable as bold text
    def type_string
      string =
        if @activity.object == 'vote'
          'stem'
        else
          @activity.trackable_class.label.downcase
        end
      string.to_s
    end
  end
end
