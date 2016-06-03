module Argu
  class ActivityString
    include ActionView::Helpers, ProfilesHelper
    include ActionDispatch::Routing
    include Rails.application.routes.url_helpers

    # Params:
    # +activity+:: The Activity to generate the activity_string for
    # +embedded_link+:: Set to true to embed an anchor link (defaults to false)
    def initialize(activity, embedded_link = false)
      @activity = activity
      @embedded_link = embedded_link
    end

    def to_s
      default = I18n.t("activities.default.#{@activity.action}",
                       owner: owner_string,
                       type: type_string,
                       subject: subject_string,
                       parent: parent_string)
      I18n.t("activities.#{@activity.trackable_type.tableize}.#{@activity.action}",
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
      if @embedded_link
        "[#{@activity.owner.display_name}](#{dual_profile_url(@activity.owner)})"
      else
        @activity.owner.display_name.to_s
      end
    end

    # @return [String, nil] Display name of activity.trackable.get_parent, as link or bold text
    def parent_string
      return nil unless @activity.trackable.try(:get_parent)
      if @embedded_link
        "[#{@activity.trackable.get_parent.model.display_name}](#{url_for(@activity.trackable.get_parent.model)})"
      else
        @activity.trackable.get_parent.model.display_name.to_s
      end
    end

    # @return [String, nil] Translation of pro, neutral or con
    def side_string
      return nil unless @activity.trackable.is_pro_con?
      I18n.t("activities.#{@activity.trackable_type.tableize}.#{@activity.trackable.key}",
             default: I18n.t(@activity.trackable.key))
    end

    # @return [String] Display name of activity.trackable, as link or bold text
    def subject_string
      string =
        if @activity.object == 'comment'
          I18n.t("#{@activity.trackable_type.tableize}.type").downcase
        else
          @activity.trackable.try(:display_name)
        end
      @embedded_link ? "[#{string}](#{url_for(@activity.trackable)})" : string.to_s
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
