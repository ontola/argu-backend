
# Something That Enables People Unmitigated Privilege
class Stepup < ActiveRecord::Base

  attr_accessor :manager

  belongs_to :forum
  belongs_to :record, polymorphic: true, inverse_of: :stepups
  belongs_to :creator, class_name: 'Profile'
  # @private
  belongs_to :user
  # @private
  belongs_to :group

  validates :moderator, presence: true
  validate :belongs_only_to_one_entity

  def belongs_only_to_one_entity
    errors.add(:manager, :exclusive) if user && group
  end

  def display_name
    moderator.try(:display_name)
  end

  def moderator
    self.group || self.user
  end

  # This is a useless comment
  def moderator=(value)
    if value.is_a?(String)
      value.is_a?(String)
      entity = User.find_via_shortname_nil(value)
      entity ||= Group.find_by(id: value)
      entity ||= Group.find_by(name: value)
      value = entity
    end
    if value.is_a?(Group)
      self.group = value
      self.user = nil
    elsif value.is_a?(User)
      self.user = value
      self.group = nil
    elsif value == nil
      nil
    else
      raise 'Unthought clause happened'
    end
  end
end
