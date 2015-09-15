class Activity < PublicActivity::Activity
  include ArguBase
  has_many :notifications, dependent: :destroy
  belongs_to :owner, class_name: 'Profile'
  belongs_to :forum

  scope :since, ->(from_time = nil) { where('created_at < :from_time', {from_time: from_time}) if from_time.present? }

  def action
    key.split('.').last
  end

  def self.cascaded_move_sql(ids, old_tenant, new_tenant)
    sql = ''

    notifications_ids = Notification
                            .where(activity_id: ids)
                            .pluck(:id)

    sql << self.migration_base_sql(self, new_tenant, old_tenant) +
        "where trackable_id IS NOT NULL AND id IN (#{ids.join(',')}); "
    #sql << Notification.cascaded_move_sql(notifications_ids, old_tenant, new_tenant) if notifications_ids.present?
    sql
  end

  def object
    trackable_type.downcase
  end

  def followers
    follower_collector = "#{object}_follower_collector".classify.safe_constantize
    if follower_collector
      follower_collector.new(self).send(action)
    else
      []
    end
  end
end
