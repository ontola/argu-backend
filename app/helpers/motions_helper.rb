include ActsAsTaggableOn::TagsHelper
module MotionsHelper
  def back_to_motion(resource)
    concat content_tag 'h1', t("#{resource.class_name}.new.header", side: pro_translation(resource))
    link_to resource.motion.title, motion_path(resource.motion), class: 'btn btn-white'
  end

  def pro_side(resource)
    %w(pro true).index(params[:pro] || resource.pro.to_s) ? 'pro' : 'con'
  end

  def pro_translation(resource)
    %w(pro true).index(params[:pro] || resource.pro.to_s) ? t("#{resource.class.to_s.pluralize.downcase}.pro") : t("#{resource.class.to_s.pluralize.downcase}.con")
  end

  def progress_bar_width(model, side)
    supplemented_values = [model.votes_pro_percentage < 5 ? 5 : model.votes_pro_percentage,
                           model.votes_neutral_percentage < 5 ? 5 : model.votes_neutral_percentage,
                           model.votes_con_percentage < 5 ? 5 : model.votes_con_percentage]
    overflow = supplemented_values.inject(&:+) - 100
    return supplemented_values[0] - (overflow*(model.votes_pro_percentage/100.to_f)) if side == :pro
    return supplemented_values[1] - (overflow*(model.votes_neutral_percentage/100.to_f)) if side == :neutral
    return supplemented_values[2] - (overflow*(model.votes_con_percentage/100.to_f)) if side == :con
  end

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
    {
        actor: actor,
        groups: groups
    }.merge(motion_vote_props(motion, vote))
  end

  def motion_vote_props(motion, vote)
    {
        object_type: 'motion',
        object_id: motion.id,
        current_vote: vote.for,
        vote_url: motion_show_vote_path(motion),
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
    }
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

end
