class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new #Guest users
    if user.role? :coder
        #The coder can do anything
        can :manage, :all
    elsif user.role? :admin
        #The admin can manage all the generic objects
        can :manage, [Statement, 
                      Argument,
                      Statementargument,
                      Comment,
                      Profile,
                      Revision,
                      Vote]
    elsif user.role? :user
        #A general user can manage it's own profile and comments
        #But can't delete general goods
        can :read, :all
        can :create, [Statement, Argument, Statementargument]
        cannot :delete, [Statement, Argument, Statementargument]
        cannot [:update, :delete], [Version, Statementargument]
        can [:edit, :update, :delete], Profile do |profile|
            user.profile == profile
        end
        can [:edit, :update, :delete], Comment do |comment|
            comment.try(:user) == user
        end
        can [:edit, :update, :delete], Vote do |vote|
            vote.user_id == user.id
        end
    else
        #Guests (non-registered) are only able to read general goods
        can :read, [Statement,
                    Argument,
                    Comment,
                    Profile]
    end
        

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
