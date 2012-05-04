class Vote < ActiveRecord::Base
  has_one :statementargument
  has_one :user

  has_restful_permissions

  attr_accessible :statementargument_id, :user_id, :vote_type

  def creatable_by?(user)
    user.clearance <= Settings['permissions.create.vote']
  end
  def updatable_by?(user)
    user.clearance <= Settings['permissions.update.vote']
  end
  def destroyable_by?(user)
    user.clearance <= Settings['permissions.destroy.vote']
  end
end
