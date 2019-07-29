# frozen_string_literal: true

class Tenant < ApplicationRecord
  has_one :page, foreign_key: :uuid, primary_key: :root_id, inverse_of: :tenant, dependent: false

  def host
    iri_prefix.split('/').first
  end

  def path
    iri_prefix.split('/')[1..-1].join('/')
  end
end
