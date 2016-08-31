module StateGenerators
  module ModelConverters
    include MotionsHelper

    def vote_item(vote)
      {
        id: vote.id,
        voteableId: vote.voteable.id,
        voteableType: vote.voteable.class_name,
        side: vote.for
      }
    end

    def motion_item(motion)
      {
        id: motion.id,
        title: motion.display_name,
        distribution: motion_vote_counts(motion)
      }
    end
  end
end
