include ActsAsTaggableOn::TagsHelper
module MotionsHelper
  def back_to_motion(resource)
    concat content_tag 'h1', t("#{resource.class_name}.new.header", side: pro_translation(resource))
    link_to resource.motion.title, motion_path(resource.motion), class: "btn btn-white"
  end

  def pro_side(resource)
    %w(pro true).index(params[:pro] || resource.pro.to_s) ? "pro" : "con"
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

  def motion_vote_props(motion, vote)
    {
        object_type: 'motion',
        object_id: motion.id,
        current_vote: vote.for,
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
    divided = true
    link_items = []
    mo_po = policy(motion)
    if mo_po.update?
      link_items << link_item(t('update'), edit_motion_path(motion), fa: 'pencil')
    end
    if mo_po.trash?
      link_items << link_item(t('trash'), motion_path(motion), data: {confirm: t('trash_confirmation'), method: 'delete', 'skip-pjax' => 'true'}, fa: 'trash')
    end
    if mo_po.destroy?
      link_items << link_item(t('destroy'), motion_path(motion, destroy: true), data: {confirm: t('destroy_confirmation'), method: 'delete', 'skip-pjax' => 'true'}, fa: 'close')
    end
    if active_for_user?(:notifications, current_user)
      if current_profile.following?(motion)
        link_items << link_item(t('forums.unfollow'), follows_path(motion_id: motion.id), fa: 'bell-slash', data: {method: 'delete', 'skip-pjax' => 'true'})
      else
        link_items << link_item(t('forums.follow'), follows_path(motion_id: motion.id), fa: 'bell', data: {method: 'create', 'skip-pjax' => 'true'})
      end
    end
    dropdown_options(t('menu'), [{items: link_items}], fa: 'fa-gear')
  end

end
