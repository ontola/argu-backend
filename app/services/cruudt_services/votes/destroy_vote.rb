# frozen_string_literal: true
class DestroyVote < DestroyService
  include AnalyticsHelper

  private

  def after_save
    super
    send_event category: 'votes',
               action: 'destroy',
               label: resource.for,
               user: resource.publisher
  end
end
