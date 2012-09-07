class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new #Guest users

    if user.role? :coder
        #The coder can do anything
        can :manage, :all
    elsif user.role? :admin
        #The admin can manage all the generic objects
        can :manage, :statements
        can :manage, :arguments
        can :manage, :statementarguments
        can :manage, :comments
        can :manage, :profiles
        can :manage, :revisions
        can :manage, :votes
    elsif user.role? :user
        #A general user can manage it's own profile and comments
        #But can't delete general goods
        can :read, :all
        can :create, :statements
        can :create, :arguments
        can :create, :statementarguments
        cannot :delete, :statements
        cannot :delete, :arguments
        cannot :update, :revisions
        cannot :update, :statementarguments
        cannot :delete, :statementarguments
        can :manage, Profile do |profile|
            user.profile == profile
        end
        can :manage, Comment do |comment|
            comment.try(:user) == user
        end
        can :manage, Vote do |vote|
            vote.try(:user) == user
        end
    else
        #Guests (non-registered) are only able to read general goods
        can :read, :statements
        can :read, :arguments
        can :read, :comments
        can :read, :profiles
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
