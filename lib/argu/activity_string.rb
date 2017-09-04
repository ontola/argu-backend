# frozen_string_literal: true

module Argu
  class ActivityString
    include ProfilesHelper
    include ActionView::Helpers
    include ActionDispatch::Routing
    include Rails.application.routes.url_helpers

    # Generates an activity string for an activity in the sense of: 'Foo responded to your Bar'
    # @param [string] activity The Activity to generate the activity_string for
    # @param [User] user The User to generate the activity_string for
    # @param [bool] embedded_link Set to true to embed an anchor link (defaults to false)
    def initialize(activity, user, embedded_link = false)
      @activity = activity
      @user = user
      @embedded_link = embedded_link
    end

    def to_s
      default = I18n.t(translation_key('activities.default'),
                       owner: owner_string,
                       type: type_string,
                       subject: subject_string,
                       parent: parent_string)
      I18n.t(translation_key("activities.#{@activity.trackable_type.tableize}"),
             owner: owner_string,
             type: type_string,
             subject: subject_string,
             parent: parent_string,
             side: side_string,
             group_singular: group_singular_string,
             default: default).html_safe
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
      if @embedded_link && @activity.owner_id.positive?
        "[#{string}](#{dual_profile_url(@activity.owner, only_path: false)})"
      else
        string.to_s
      end
    end

    # @return [String, nil] Display name of activity.trackable.parent_edge, as link or bold text
    def parent_string
      recipient = @activity.recipient_type == 'VoteEvent' ? @activity.recipient&.voteable : @activity.recipient
      return @activity.audit_data.try(:[], 'recipient_name') if recipient.nil?
      @embedded_link ? "[#{recipient.display_name}](#{polymorphic_url(recipient)})" : recipient.display_name
    end

    # @return [String, nil] Translation of pro, neutral or con
    def side_string
      return nil unless @activity.trackable.present? && @activity.trackable.is_pro_con?
      I18n.t("activities.#{@activity.trackable_type.tableize}.#{@activity.trackable.key}",
             default: I18n.t(@activity.trackable.key))
    end

    # @return [String] Display name of activity.trackable, as link or bold text
    def subject_string
      string =
        if @activity.object == 'comment'
          I18n.t("#{@activity.trackable_type.tableize}.type").downcase
        elsif @activity.trackable.present?
          @activity.trackable.try(:display_name)
        else
          @activity.audit_data.try(:[], 'trackable_name')
        end
      if @embedded_link && @activity.trackable.present?
        url =
          if @activity.object == 'decision'
            if @activity.trackable.present? && @activity.recipient.present?
              motion_decision_url(@activity.recipient_edge, id: @activity.trackable.step)
            end
          else
            polymorphic_url(@activity.trackable)
          end
        "[#{string}](#{url})"
      else
        string.to_s
      end
    end

    def sub_action_key
      return unless @activity.trackable_type == 'Decision' && @activity.action == 'forwarded'
      if @activity.trackable.forwarded_user == @user
        :to_you
      elsif @activity.trackable.forwarded_user.nil? &&
          @user.profile.group_ids.include?(@activity.trackable.forwarded_group)
        :to_group
      else
        :to_any
      end
    end

    def translation_key(base_key)
      [base_key, @activity.action, sub_action_key].compact.join('.')
    end

    # @return [String] Type name of activity.trackable as bold text
    def type_string
      string =
        if @activity.object == 'vote'
          'stem'
        else
          I18n.t("#{@activity.trackable_type.tableize}.type").downcase
        end
      string.to_s
    end
  end
end
