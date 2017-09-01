# frozen_string_literal: true

module DefaultPolicyResults
  def everybody_results
    {
      guest: true,
      creator: true,
      user: true,
      spectator: true,
      member: true,
      non_member: true,
      manager: true,
      super_admin: true,
      staff: true
    }
  end

  def nobody_results
    {
      guest: false,
      user: false,
      spectator: false,
      member: false,
      non_member: false,
      manager: false,
      super_admin: false,
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
  alias feed_results show_results

  def follow_results
    everybody_results.merge(non_member: false)
  end

  def create_results
    everybody_results.merge(spectator: false, non_member: false)
  end

  def manager_plus_results
    nobody_results.merge(manager: true, super_admin: true, staff: true)
  end
  alias trash_results manager_plus_results
  alias log_results manager_plus_results

  def update_results
    manager_plus_results.merge(creator: true)
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
