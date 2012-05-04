class Vote < ActiveRecord::Base
  has_one :statementargument
  has_one :user

  has_restful_permissions

  attr_accessible :statementargument_id, :user_id, :vote_type

  def creatable_by?(user)
    Settings['permissions.create.vote'] >= user.clearance unless user.clearance.nil?
  end
  def updatable_by?(user)
    Settings['permissions.update.vote'] >= user.clearance unless user.clearance.nil?
  end
  def destroyable_by?(user)
    Settings['permissions.destroy.vote'] >= user.clearance unless user.clearance.nil?
  end
end
