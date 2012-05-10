include HasRestfulPermissions

class Vote < ActiveRecord::Base
  belongs_to :statementargument, counter_cache: true
  has_one :user

  has_restful_permissions

  attr_accessible :statementargument_id, :user_id, :vote_type

class << self 
  def creatable_by?(user)
    Settings['permissions.create.vote'] >= user.clearance unless user.clearance.nil?
  end
end
  def updatable_by?(user)
    Settings['permissions.update.vote'] >= user.clearance unless user.clearance.nil?
  end

  def destroyable_by?(user)
    unless user.nil?
      if user.id == self.user_id
        true
      else
        Settings['permissions.destroy.vote'] >= user.clearance
      end
    end
  end

end
