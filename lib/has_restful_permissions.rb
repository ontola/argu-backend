class PermissionViolation < StandardError; end

module HasRestfulPermissions
 
  # call this in resource class
  def has_restful_permissions
    extend  ClassMethods
    include InstanceMethods
  end
 
  module InstanceMethods
    # permission rules, override these in the resource class

    def creatable_by?(user)
      Settings['permissions.default.create'] >= user.clearance unless user.clearance.nil?
    end
 
    # Returns true if actor can destroy this resource.
    def destroyable_by?(user)
      Settings['permissions.default.create'] >= user.clearance unless user.clearance.nil?
    end
 
    # Returns true if actor can update this resource.
    def updatable_by?(user)
      Settings['permissions.default.create'] >= user.clearance unless user.clearance.nil?
    end
 
    # Returns true if actor can view this resource.
    def viewable_by?(user)
      Settings['permissions.default.create'] >= user.clearance unless user.clearance.nil?
    end

    def user_creatable_by?(creating_user)
      Settings['permissions.default.create'] >= user.clearance unless user.clearance.nil?
    end
 
    def owned_by?(user)
      false
    end
 
  end
 
  module ClassMethods
    # Returns true if actor can view a list of resources of this class.
    def listable_by?(user)
      Settings['permissions.default.listable'] >= user.clearance unless user.clearance.nil?
    end
 
    def creatable_by?(user)
      Settings['permissions.default.create'] >= user.clearance unless user.clearance.nil?
    end
  end
 
end

 
ActiveRecord::Base.send :extend, HasRestfulPermissions