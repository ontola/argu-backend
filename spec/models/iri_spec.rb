# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Iri's", type: :model do
  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::UrlFor

  define_spec_objects
  let(:url) { url_for([subject, protocol: :http]) }

  RSpec.shared_examples_for 'iri matches route' do
    it 'matches #iri with route' do
      expect(subject.iri.to_s).to eq(url)
    end
  end

  context 'Page' do
    subject { argu }
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
    let(:url) { url_for([subject.profileable, protocol: :http]) }
    it_behaves_like 'iri matches route'
  end

  context 'Page profile' do
    subject { argu.profile }
    let(:url) { url_for([subject.profileable, protocol: :http]) }
    it_behaves_like 'iri matches route'
  end

  context 'Group' do
    subject { Group.first }
    it_behaves_like 'iri matches route'
  end

  context 'GroupMembership' do
    subject { GroupMembership.first }
    it_behaves_like 'iri matches route'
  end

  context 'MediaObject' do
    subject { MediaObject.first }
    it_behaves_like 'iri matches route'
  end

  context 'Grant' do
    subject { Grant.first }
    it_behaves_like 'iri matches route'
  end

  context 'with root' do
    let(:id) { subject.edge.fragment }
    let(:url) { url_for([subject.class_name.singularize, id: id, root_id: root_id, protocol: :http]) }
    let(:root_id) { argu.url }

    context 'Forum' do
      subject { freetown }
      let(:id) { subject.url }
      it_behaves_like 'iri matches route'
    end

    context 'LinkedRecord' do
      subject { linked_record }
      let(:url) do
        url_for(
          [
            subject.parent_model(:forum),
            subject,
            root_id: subject.parent_model(:page).url,
            protocol: :http
          ]
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
        motion_decision_url(subject.parent_edge.fragment, subject.step, root_id: root_id, protocol: :http)
      end
      it_behaves_like 'iri matches route'
    end

    context 'VoteEvent' do
      subject { vote_event }
      let(:url) do
        motion_vote_event_url(subject.voteable.edge.fragment, subject.edge.fragment, root_id: root_id, protocol: :http)
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
  end
end
