module HeaderHelper
  include DropdownHelper, ActionView::Helpers::TextHelper

  def suggested_forums
    return nil if current_user.present?
    fresh_forums = "id NOT IN (#{current_profile.joined_forum_ids || '0'}) AND visibility ="\
                   " #{Forum.visibilities[:open]}"
    @suggested_forums ||= Forum.where(fresh_forums)
  end

  def notifications_state
    {
      unreadCount: policy_scope(Notification)
                     .where('read_at is NULL')
                     .order(created_at: :desc)
                     .count,
      notifications: []
    }
  end

  def notification_dropdown_items
    dropdown_options('',
                     [{
                       type: 'notifications',
                       notifications: [],
                       lastNotification: nil,
                       loadMore: true
                     }],
                     trigger: {
                       type: 'notifications',
                       triggerClass: 'navbar-item'
                     },
                     contentClassName: 'notifications notification-container')
  end

  def public_forum_items(limit= 10)
    items = []
    Forum
        .public_forums
        .includes(:default_profile_photo, :shortname)
        .select { |f| ['nederland', 'utrecht', 'houten', 'heerenveen', 'feedback'].include?(f.shortname.shortname) }
        .first(limit)
        .each do |forum|
          items << link_item(forum.display_name, forum_path(forum), image: forum.default_profile_photo.url(:icon))
        end
    items
  end

  def profile_membership_items
    ids = current_profile.present? ? current_profile.forum_ids : []
    Shortname
      .shortname_owners_for_klass('Forum', ids)
      .includes(owner: :default_profile_photo)
      .map do |shortname|
        link_item(shortname.owner.display_name,
                  forum_path(shortname.shortname),
                  image: shortname.owner.default_profile_photo.url(:icon))
      end
  end
end
