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
                      Comment,
                      Profile,
                      Revision,
                      Vote]
    elsif user.role? :user
        can :read, :all                                         #Not sure yet
        can :create, [Statement, Argument, Comment]
        can [:revisions, :allrevisions], Statement              #View revisions
        can :placeComment, [Statement, Argument, Comment]
        cannot :delete, [Statement, Argument ]                  #No touching!
        cannot [:update, :delete], [Version]                    #I said, no touching!
        can [:edit, :update, :delete], Profile do |profile|     #Do whatever you want with your own profile
            user.profile == profile
        end
        can [:show, :update], User do |u|                       #Same goes for your persona
            user.id == u.id
        end
        can [:edit, :update, :delete], Comment do |comment|     #And your comments
            comment.try(:user) == user
        end
        can [:manage], Vote                                     #Freedom in democracy
    else
        cannot :manage, [Statement,                             #not loggin in and in closed beta, so bugger off!
                         Argument,
                         Comment,
                         Profile,
                         Vote,
                         Version,
                         Revision]
    end
  end
end
