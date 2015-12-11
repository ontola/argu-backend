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

  def motion_items(motion)
    link_items = []
    mo_po = policy(motion)
    if mo_po.update?
      link_items << link_item(t('edit'), edit_motion_path(motion), fa: 'pencil')
    end
    if mo_po.trash?
      link_items << link_item(t('trash'), motion_path(motion), data: {confirm: t('trash_confirmation'), method: 'delete', 'skip-pjax' => 'true'}, fa: 'trash')
    end
    if mo_po.destroy?
      link_items << link_item(t('destroy'), motion_path(motion, destroy: true), data: {confirm: t('destroy_confirmation'), method: 'delete', 'skip-pjax' => 'true'}, fa: 'close')
    end
    dropdown_options(t('menu'), [{items: link_items}], fa: 'fa-gear')
  end

  def motion_timeline_props(motion)
    merge_state({
      timelines: {
        '1' => {
          id: 1,
          currentPhase: 2,
          phaseCount: 4,
          activePointId: nil,
          points: [1, 2, 3, 4, 5, 6]
        }
      },
      points: [
        {
          id: 1,
          timelineId: 1,
          type: 'phase',
          itemId: 1
        },
        {
          id: 2,
          timelineId: 1,
          type: 'phase',
          itemId: 2
        },
        {
          id: 3,
          timelineId: 1,
          type: 'phase',
          itemId: 3
        },
        {
          id: 4,
          timelineId: 1,
          type: 'update',
          itemId: 1
        },
        {
          id: 5,
          timelineId: 1,
          type: 'update',
          itemId: 2
        },
        {
          id: 6,
          timelineId: 1,
          type: 'update',
          itemId: 3
        },
        {
          id: 7,
          timelineId: 1,
          type: 'phase',
          itemId: 4
        }
      ],
      phases: [
        {
          id: 1,
          timelineId: 1,
          index: 0,
          title: 'Beleidsfase',
          content: 'Fasebeschrijving voor fase 1'
        },
        {
          id: 2,
          timelineId: 1,
          index: 1,
          title: 'Initiëren',
          content: 'Fasebeschrijving voor fase 2'
        },
        {
          id: 3,
          timelineId: 1,
          index: 2,
          title: 'Behandelen',
          content: 'Fasebeschrijving voor fase drie'
        },
        {
        id: 4,
          timelineId: 1,
          index: 3,
          title: 'Einde',
          content: ''
        }
      ],
      updates: [
        {
          id: 1,
          phaseId: 1,
          title: 'An update',
          content: 'description of the update',
          creatorId: 1,
          createdAt: Time.current,
          dateline: {
            date: Time.current - 1.hour,
            location: ''
          }
        },
        {
          id: 2,
          phaseId: 1,
          title: 'Update 2',
          content: 'description of update 2',
          creatorId: 1,
          createdAt: Time.current,
          dateline: {
            date: Time.current - 1.hour,
            location: ''
          }
        },
        {
          id: 3,
          phaseId: 2,
          title: 'Another update',
          content: 'Update is in the second phase',
          creatorId: 1,
          createdAt: Time.current,
          dateline: {
            date: Time.current - 1.hour,
            location: ''
          }
        }
      ],
      profiles: [
        {
          id: 1,
          displayName: 'Some creator',
          url: 'https://argu.co/u/someone'
        }
      ]
    })

    {
      timeLineId: 1
    }
  end

end
