# frozen_string_literal: true

class VotesController < EdgeableController # rubocop:disable Metrics/ClassLength
  skip_before_action :verify_setup

  has_collection_create_action(
    image: lambda {
      Vote.create_image(resource.filter[NS.schema.option]&.first, resource.parent.upvote_only?)
    },
    label: lambda {
      Vote.create_label(association, resource.filter[NS.schema.option]&.first, resource.parent.upvote_only?)
    },
    submit_label: lambda {
      Vote.create_label(association, resource.filter[NS.schema.option]&.first, resource.parent.upvote_only?)
    },
    favorite: lambda {
      resource.filter[NS.schema.option].present? && (
        !resource.parent.upvote_only? || resource.filter[NS.schema.option] == %i[yes]
      )
    }
  )
  has_resource_trash_action(
    image: -> { Vote.create_image(resource.option, resource.parent.upvote_only?) },
    label: -> { Vote.create_label(association, resource.option, resource.parent.upvote_only?) },
    submit_label: -> { Vote.create_label(association, resource.option, resource.parent.upvote_only?) }
  )
  has_singular_destroy_action(
    image: -> { Vote.create_image(resource.option, resource.parent.upvote_only?) },
    label: -> { Vote.create_label(association, resource.option, resource.parent.upvote_only?) },
    submit_label: -> { Vote.create_label(association, resource.option, resource.parent.upvote_only?) }
  )
  has_singular_trash_action(
    image: -> { Vote.create_image(resource.option, resource.parent.upvote_only?) },
    label: -> { Vote.create_label(association, resource.option, resource.parent.upvote_only?) },
    submit_label: -> { Vote.create_label(association, resource.option, resource.parent.upvote_only?) }
  )

  private

  def active_response_success_message
    case action_name
    when 'create'
      I18n.t('votes.alerts.success')
    when 'trash', 'destroy'
      I18n.t('votes.alerts.trashed')
    else
      super
    end
  end

  def allow_empty_params?
    true
  end

  def authorize_action
    return super unless action_name == 'create'

    method = authenticated_resource.persisted? ? :update? : :create?
    authorize authenticated_resource, method
  end

  def broadcast_vote_counts
    RootChannel.broadcast_to(tree_root, hex_delta(counter_cache_delta(authenticated_resource)))
  end

  def create_meta
    data = super
    data << invalidate_trash_action
    data
  end

  def create_success
    super
    broadcast_vote_counts
  end

  def current_resource
    return super unless action_name == 'create' && current_user.guest?

    resource = super
    resource.singular_resource = true
    resource
  end

  def destroy_success
    super
    broadcast_vote_counts
  end

  def execute_action
    return super unless action_name == 'create'
    return super unless unmodified?

    head 304
  end

  def invalidate_trash_action
    [
      current_resource.action(:trash).iri,
      NS.sp.Variable,
      NS.sp.Variable,
      delta_iri(:invalidate)
    ]
  end

  def redirect_param
    params.require(:vote).permit(:redirect_url)[:redirect_url]
  end

  def redirect_location
    if authenticated_resource.persisted?
      authenticated_resource.iri
    else
      authenticated_resource.voteable.iri
    end
  end

  def singular_added_delta(resource)
    [same_as_statement(resource.singular_iri, resource.iri)]
  end

  def singular_removed_delta(resource)
    [[current_vote_iri(resource.parent), NS.schema.option, NS.argu[:abstain], delta_iri(:replace)]]
  end

  def trash_meta
    destroy_meta
  end

  def unmodified?
    create_service.resource.persisted? && !create_service.resource.option_changed?
  end
end
