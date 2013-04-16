class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new #Guest users
    if user.role? :coder
        #The coder can do anything
        can :manage, :all
    elsif user.role? :admin
        #The admin can manage all the generic objects
        can [:manage, :revisions, :allrevisions],
            [Statement, 
             Argument,
             Comment,
             Profile,
             Vote]
        can :manage, User do |u|
          user == u
        end
    elsif user.role? :user
        cannot :manage, User do |u|
          user != u
        end
        can :read, :all                                         #read by default, should be changed later
        can :create, [Statement, Argument, Comment]
        can :update, [Statement, Argument] do |item|
          user == item.creator
        end
        can [:revisions, :allrevisions], [Statement, Argument]              #View revisions
        can :placeComment, [Statement, Argument, Comment]
        cannot :delete, [Statement, Argument ]                  #No touching!
        cannot [:update, :delete], [Version]                    #I said, no touching!
        can [:edit, :update, :delete], Profile do |profile|     #Do whatever you want with your own profile
            user.profile == profile
        end
        can [:show, :update], User do |u|                       #Same goes for your persona
            user == u
        end
        can [:edit, :update, :delete], Comment do |comment|     #And your comments
            comment.try(:user) == user
        end
        can [:manage], Vote do |vote|                           #Freedom in democracy
            user.id == vote.voter_id
        end
    else
        cannot [:manage, :revisions, :allrevisions],            #not loggin in and in closed beta, so bugger off!
               [Statement,
                Argument,
                Comment,
                Profile,
                Vote,
                Version]
    end
  end
end
