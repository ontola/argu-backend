# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '#iri_cache', type: :model do
  define_spec_objects
  let(:user) { create(:user) }

  context 'iri of a cached user' do
    subject { user.iri_cache }

    it { is_expected.to eq("/u/#{user.url}") }
  end

  context 'iri of a cleared user' do
    subject { ActsAsTenant.with_tenant(argu) { user.update!(iri_cache: nil) } && user.root_relative_iri.to_s }

    it { is_expected.to eq("/u/#{user.url}") }
  end

  context 'iri of a user after updated shortname' do
    subject { user.update!(url: 'new_url') && user.reload.root_relative_iri.to_s }

    it { is_expected.to eq('/u/new_url') }
  end
end
