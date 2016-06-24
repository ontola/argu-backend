class TraitListener
  def initialize(resource)
    @resource = resource
  end

  # Adds 3 pro and 3 con arguments to the resource
  def with_arguments
    FactoryGirl.create_list(
      :argument, 3,
      motion: @resource,
      forum: @resource.forum)
    FactoryGirl.create_list(
      :argument, 3,
      motion: @resource,
      forum: @resource.forum,
      pro: false,
      is_trashed: true)
  end

  # Adds a follower to the edge of the resource
  # See {Follow}
  # @note Adds an extra {Notification} on associated resource creation
  def with_follower
    FactoryGirl.create(
      :follow,
      follower: FactoryGirl.create(:user, :follows_reactions_directly),
      followable: @resource.edge)
  end

  # Adds a discussion group with 2 GroupResponses and a visible and a hidden group without reponses
  # to the forum of the resource
  def with_group_responses
    FactoryGirl.create_list(
      :group_response, 2,
      group: FactoryGirl.create(
        :group,
        visibility: :discussion,
        forum: @resource.forum))
    FactoryGirl.create(
      :group,
      visibility: :hidden,
      forum: @resource.forum)
    FactoryGirl.create(
      :group,
      visibility: :visible,
      forum: @resource.forum)
  end

  # Adds 2 published and 2 trashed motions to the resource
  def with_motions
    FactoryGirl.create_list(
      :motion, 2,
      question: question,
      forum: question.forum)
    FactoryGirl.create_list(
      :motion, 2,
      question: question,
      forum: question.forum,
      is_trashed: true)
  end

  # Adds 2 pro, 2 neutral and 2 con votes to the resource
  def with_votes
    FactoryGirl.create_list(
      :vote, 2,
      voteable: @resource,
      for: :pro)
    FactoryGirl.create_list(
      :vote, 2,
      voteable: @resource,
      for: :neutral)
    FactoryGirl.create_list(
      :vote, 2,
      voteable: @resource,
      for: :con)
  end
end
