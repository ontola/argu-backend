# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Discussions', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:index_path) { subject_parent.collection_iri(:discussions).path }
  let(:non_existing_index_path) { '/non_existing/discussions' }
  let(:subject_parent) { freetown }

  context 'for discoverable forum' do
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
