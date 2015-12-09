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
    {
      timeLineId: 1,
      phases: [
        {
          id: 1,
          index: 0,
          title: 'Fase 1',
          content: 'Fasebeschrijving voor fase 1'
        },
        {
          id: 2,
          index: 1,
          title: 'Fase 2',
          content: 'Fasebeschrijving voor fase 2'
        }
      ]
    }
  end

end
