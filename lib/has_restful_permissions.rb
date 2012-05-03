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
      user.clearance < Settings['permissions.default.create']
    end
 
    # Returns true if actor can destroy this resource.
    def destroyable_by?(user)
      user.clearance < Settings['permissions.default.create']
    end
 
    # Returns true if actor can update this resource.
    def updatable_by?(user)
      user.clearance < Settings['permissions.default.create']
    end
 
    # Returns true if actor can view this resource.
    def viewable_by?(user)
      user.clearance < Settings['permissions.default.create']
    end
 
    def owned_by?(user)
      false
    end
 
  end
 
  module ClassMethods
    # Returns true if actor can view a list of resources of this class.
    def listable_by?(user)
      user.clearance < Settings['permissions.default.listable']
    end
 
    def creatable_by?(user)
      user.clearance < Settings['permissions.default.create']
    end
  end
 
end
 
ActiveRecord::Base.send :extend, HasRestfulPermissions