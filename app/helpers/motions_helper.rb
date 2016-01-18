include ActsAsTaggableOn::TagsHelper
module MotionsHelper

  def motion_combi_vote_props(actor, motion, vote)
    groups = motion.forum.groups.collect do |group|
      {
          id: group.id,
          name: group.name,
          name_singular: group.name_singular,
          icon: group.icon,
          responses_left: group.responses_left(motion, actor),
          actor_group_responses: group.responses_for(motion, actor)
      }
    end
    localized_react_component({
        actor: actor,
        groups: groups
    }.merge(motion_vote_props(motion, vote)))
  end

  def motion_vote_props(motion, vote, opts={})
    opts.merge({
        object_type: 'motion',
        object_id: motion.id,
        current_vote: vote.for,
        vote_url: motion_show_vote_path(motion),
        total_votes: motion.total_vote_count,
        distribution: {
          pro: motion.votes_pro_count,
          neutral: motion.votes_neutral_count,
          con: motion.votes_con_count
        },
        percent: {
            pro: motion.votes_pro_percentage,
            neutral: motion.votes_neutral_percentage,
            con: motion.votes_con_percentage
        }
    })
  end

  def motion_timeline_props(motion)
    points = [
      {
        type: 'point',
        id: 1,
        timelineId: 1,
        itemType: 'phase',
        itemId: 1
      },
      {
        type: 'point',
        id: 2,
        timelineId: 1,
        itemType: 'phase',
        itemId: 2
      },
      {
        type: 'point',
        id: 3,
        timelineId: 1,
        itemType: 'phase',
        itemId: 3
      },
      {
        type: 'point',
        id: 4,
        timelineId: 1,
        itemType: 'update',
        itemId: 1
      },
      {
        type: 'point',
        id: 5,
        timelineId: 1,
        itemType: 'update',
        itemId: 2
      },
      {
        type: 'point',
        id: 6,
        timelineId: 1,
        itemType: 'update',
        itemId: 3
      },
      {
        type: 'point',
        id: 7,
        timelineId: 1,
        itemType: 'phase',
        itemId: 4
      }
    ]

    active_point_id = params.fetch(:timeline, {}).fetch(:activePointId, nil).presence.try(:to_i)
    active_point = points[points.find_index { |p| p[:id] === active_point_id }] if active_point_id.present?

    merge_state({
      timelines: {
        activeTimelineId: 1,
        collection: {
          '1' => {
            type: 'timeline',
            id: 1,
            currentPhase: 2,
            phaseCount: 4,
            activePointId: active_point_id,
            points: [1, 2, 3, 4, 5, 6]
          }
        }
      },
      points: {
        activePointId: active_point_id,
        activePoint: active_point,
        collection: points
      },
      phases: [
        {
          type: 'phase',
          id: 1,
          timelineId: 1,
          index: 0,
          title: 'Beleidsfase',
          content: 'Fasebeschrijving voor fase 1',
          startDate: Time.current - 1.hours,
          endDate: Time.current + 2.hours
        },
        {
          type: 'phase',
          id: 2,
          timelineId: 1,
          index: 1,
          title: 'Initiatiefase',
          content: 'Fasebeschrijving voor fase 2',
          startDate: Time.current + 2.hours,
          endDate: Time.current + 5.hours
        },
        {
          type: 'phase',
          id: 3,
          timelineId: 1,
          index: 2,
          title: 'Behandelfase',
          content: 'Fasebeschrijving voor fase drie',
          startDate: Time.current + 5.hours,
          endDate: Time.current + 6.hours
        },
        {
          type: 'phase',
          id: 4,
          timelineId: 1,
          index: 3,
          title: 'Einde',
          content: '',
          startDate: Time.current + 6.hours,
          endDate: nil
        }
      ],
      updates: [
        {
          id: 1,
          type: 'update',
          title: 'An update',
          content: 'description of the update',
          creatorId: 1,
          createdAt: Time.current,
          dateline: {
            date: Time.current - 15.minutes,
            location: ''
          }
        },
        {
          id: 2,
          type: 'update',
          title: 'Update 2',
          content: 'Happened earlier than An Update',
          creatorId: 1,
          createdAt: Time.current,
          dateline: {
            date: Time.current - 45.minutes,
            location: ''
          }
        },
        {
          id: 3,
          type: 'update',
          title: 'Another update',
          content: 'Update is in the second phase',
          creatorId: 1,
          createdAt: Time.current,
          dateline: {
            date: Time.current + 3.hours,
            location: ''
          }
        }
      ],
      profiles: [
        {
          id: 1,
          type: 'profile',
          displayName: 'Some creator',
          url: 'https://argu.co/u/someone'
        }
      ]
    })

    {
      timelineId: 1
    }
  end

end
