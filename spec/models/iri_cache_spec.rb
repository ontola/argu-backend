# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '#iri_cache', type: :model do
  define_spec_objects

  context 'iri of a cached motion' do
    subject { motion.iri_cache }
    it { is_expected.to eq("/m/#{motion.fragment}") }
  end

  context 'iri of a cleared motion' do
    subject { motion.update!(iri_cache: nil) && motion.iri_path }
    it { is_expected.to eq("/m/#{motion.fragment}") }
  end

  context 'iri of a cached page' do
    subject { argu.iri_cache }
    it { is_expected.to eq('') }
  end

  context 'iri of a cleared page' do
    subject { argu.update!(iri_cache: nil) && argu.iri_path }
    it { is_expected.to eq('') }
  end

  context 'iri of a page after updated shortname' do
    subject { argu.update!(url: 'new_url') && argu.reload.iri_path }
    it { is_expected.to eq('') }
  end
end
