# frozen_string_literal: true

Rails.application.config.to_prepare do
  file = Rails.root.join('config/tiers.yml')
  Rails.application.config.tiers =
    YAML.safe_load(File.read(file)).each_with_object({}.with_indifferent_access) do |(tier, features), hash|
      features.each { |feature| hash[feature] = Page.tiers[tier] }
    end
end
