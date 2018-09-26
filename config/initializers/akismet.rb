# frozen_string_literal: true

Rails.application.config.rakismet.key = ENV['AKISMET_KEY']
Rails.application.config.rakismet.url = Rails.application.config.origin
