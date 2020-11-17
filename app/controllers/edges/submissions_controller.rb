# frozen_string_literal: true

class SubmissionsController < EdgeableController
  private

  def permit_params
    {
      session_id: session_id
    }
  end

  def service_creator
    return super unless current_user.guest?

    Profile.community
  end

  def service_publisher
    return super unless current_user.guest?

    User.community
  end
end
