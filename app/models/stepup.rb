
# Something That Enables People Unmitigated Privilege
class Stepup < ActiveRecord::Base

  attr_accessor :manager

  belongs_to :forum
  belongs_to :record, polymorphic: true, inverse_of: :stepups
  belongs_to :user
  belongs_to :group

  def manager
    self[:group] || self[:user]
  end

  def manager=(value)
    if value.is_a?(Group)
      self[:group] = value
      self[:user] = nil
    elsif value.is_a?(User)
      self[:user] = value
      self[:group] = nil
    else
      raise 'Unthought clause happened'
    end
  end
end
