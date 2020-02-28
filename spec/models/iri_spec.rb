# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Iri's", type: :model do
  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::UrlFor

  define_spec_objects
  let(:url) { url_for([subject, protocol: :http]) }
  let(:iri_owner) { subject }

  RSpec.shared_examples_for 'iri matches route' do
    it 'matches #iri with route' do
      expect(subject.iri.to_s).to eq(url)
    end

    it 'can be found with resource_from_iri' do
      expect(LinkedRails.resource_from_iri(subject.iri)).to eq(iri_owner)
    end
  end

  before do
    ActsAsTenant.current_tenant = argu
    Rails.application.routes.default_url_options[:host] = 'http://argu.localtest/argu'
  end

  context 'Page' do
    subject { argu }

    let(:url) { root_url[0...-1] }

    it_behaves_like 'iri matches route'
  end

  context 'User' do
    subject { create(:user) }

    it_behaves_like 'iri matches route'
  end

  context 'User without shortname' do
    subject { create(:user, :no_shortname) }

    it_behaves_like 'iri matches route'
  end

  context 'User profile' do
    subject { create(:user).profile }

    let(:iri_owner) { subject.profileable }
    let(:url) { url_for([subject.profileable, protocol: :http]) }

    it_behaves_like 'iri matches route'
  end

  context 'Page profile' do
    subject { argu.profile }

    let(:iri_owner) { subject.profileable }
    let(:url) { root_url[0...-1] }

    it_behaves_like 'iri matches route'
  end

  context 'MediaObject' do
    subject { MediaObject.first }

    it_behaves_like 'iri matches route'
  end

  context 'with root' do
    let(:id) { subject.fragment }
    let(:url) { url_for([subject.class_name.singularize, id: id, protocol: :http]) }

    context 'Forum' do
      subject { freetown }

      let(:id) { subject.url }
      let(:url) { container_node_url(subject) }

      it_behaves_like 'iri matches route'
    end

    context 'LinkedRecord' do
      subject { linked_record }

      let(:url) do
        container_node_linked_record_url(
          subject.ancestor(:forum),
          subject,
          protocol: :http
        )
      end

      it_behaves_like 'iri matches route'
    end

    context 'Question' do
      subject { question }

      it_behaves_like 'iri matches route'
    end

    context 'Motion' do
      subject { motion }

      it_behaves_like 'iri matches route'
    end

    context 'Decision' do
      subject { decision }

      let(:url) do
        motion_decision_url(subject.parent.fragment, subject.step, protocol: :http)
      end

      it_behaves_like 'iri matches route'
    end

    context 'VoteEvent' do
      subject { vote_event }

      let(:url) do
        motion_vote_event_url(subject.voteable.fragment, subject.fragment, protocol: :http)
      end

      it_behaves_like 'iri matches route'
    end

    context 'Vote' do
      subject { vote }

      it_behaves_like 'iri matches route'
    end

    context 'Argument' do
      subject { argument }

      it_behaves_like 'iri matches route'
    end

    context 'Comment' do
      subject { comment }

      it_behaves_like 'iri matches route'
    end

    context 'BlogPost' do
      subject { blog_post }

      it_behaves_like 'iri matches route'
    end

    context 'Group' do
      subject { Group.first }

      let(:url) { destroy_group_url(subject, protocol: :http) }

      let(:id) { subject.id }

      it_behaves_like 'iri matches route'
    end

    context 'GroupMembership' do
      subject { GroupMembership.first }

      let(:id) { subject.id }

      it_behaves_like 'iri matches route'
    end

    context 'Grant' do
      subject { Grant.first }

      let(:id) { subject.id }

      it_behaves_like 'iri matches route'
    end
  end
end
