# frozen_string_literal: true

class RootChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_tenant
  end

  def unsubscribed; end
end
