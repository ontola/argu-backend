# frozen_string_literal: true
class PermittedAction < ApplicationRecord
  has_many :grant_sets_permitted_actions
  has_many :grant_sets, through: :grant_sets_permitted_actions

  def self.find_or_create_by(opts = {})
    raise 'Provide atleast resource_type and action in opts' unless (%i(resource_type action) - opts.keys).empty?
    opts[:parent_type] ||= '*'
    opts[:trickles] = true if opts[:trickles].nil?
    opts[:permit] = true if opts[:permit].nil?
    super(opts)
  end
end
