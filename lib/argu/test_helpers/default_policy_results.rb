# frozen_string_literal: true

module DefaultPolicyResults
  def everybody_results
    {
      guest: true,
      creator: true,
      user: true,
      spectator: true,
      participator: true,
      initiator: true,
      non_member: true,
      moderator: true,
      administrator: true,
      staff: true
    }
  end

  def nobody_results
    {
      guest: false,
      user: false,
      spectator: false,
      participator: false,
      initiator: false,
      non_member: false,
      moderator: false,
      administrator: false,
      staff: false
    }
  end
  alias create_expired_results nobody_results
  alias create_trashed_results nobody_results
  alias move_results nobody_results
  alias convert_results nobody_results
  alias invite_results nobody_results

  def show_results
    everybody_results.merge(non_member: false)
  end

  def show_unpublished_results
    moderator_plus_results.merge(creator: true)
  end

  def show_expired_results
    show_results
  end

  def show_trashed_results
    show_results
  end

  def feed_results
    show_results
  end

  def follow_results
    show_results
  end

  def create_results
    everybody_results.merge(spectator: false, non_member: false)
  end

  def moderator_plus_results
    nobody_results.merge(moderator: true, administrator: true, staff: true)
  end

  def trash_results
    moderator_plus_results
  end

  def update_results
    moderator_plus_results.merge(creator: true)
  end

  def log_results
    update_results
  end

  def destroy_results
    nobody_results.merge(creator: true, staff: true)
  end

  def destroy_with_children_results
    {creator: false, staff: true}
  end

  def staff_only_results
    nobody_results.merge(creator: false, staff: true)
  end
end
