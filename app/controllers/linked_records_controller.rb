# frozen_string_literal: true

class LinkedRecordsController < ApplicationController
  def show
    redirect_to request.original_url.sub('/lr/', '/od/'), status: 301
  end
end
