# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Discussions', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:table_sym) { :discussions }

  context 'for page' do
    let(:subject_parent) { argu }
    let(:non_existing_index_path) { '/non_existing/discussions' }
    it_behaves_like 'get index', skip: %i[unauthorized]
  end

  context 'for discoverable forum' do
    let(:subject_parent) { freetown }
    it_behaves_like 'get index'
  end

  context 'for hidden forum' do
    let(:subject_parent) { holland }
    let(:expect_unauthorized) { expect_not_found }
    let(:expect_redirect_to_login) { expect_not_found }
    let(:expect_get_index_guest_serializer) { expect_not_found }
    it_behaves_like 'get index'
  end
end
