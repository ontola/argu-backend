# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchResult, type: :model do
  define_spec_objects
  let(:page) { 1 }
  let(:parent) { argu }
  let(:q) { 'motion' }
  let(:user_context) { UserContext.new(user: user, profile: user.profile, doorkeeper_scopes: {}) }
  let(:user) { create(:user) }

  before do
    ActsAsTenant.current_tenant = argu
    Searchkick.enable_callbacks
    Edge.reindex_with_tenant(async: false)
  end

  after do
    Searchkick.disable_callbacks
  end

  describe 'scoping' do
    context 'as user' do
      it { expect(subject.total_count).to eq(4) }
    end

    context 'as admin' do
      let(:user) { create_administrator(argu) }
      it { expect(subject.total_count).to eq(8) }
    end

    it { expect(subject(parent: unpublished_question).total_count).to eq(0) }
  end

  describe 'pagination' do
    it { expect(subject.total_count).to eq(4) }
    it { expect(subject(page_size: 3).search_result.count).to eq(3) }
    it { expect(subject(page_size: 3, page: 2).search_result.count).to eq(1) }
  end

  describe 'search in branch' do
    it { expect(subject(parent: question).total_count).to eq(1) }
    it { expect(subject(parent: motion).total_count).to eq(0) }
  end

  describe 'keeping index up to date' do
    it 'keeps trashed items in index' do
      motion.trash
      expect(subject.search_result.count).to eq(4)
    end

    it 'remove destroyed items from index' do
      motion.destroy
      expect(subject.search_result.count).to eq(3)
      expect(subject.search_result.reject(&:is_published?)).to be_empty
    end
  end

  private

  def subject(opts = {})
    SearchResult.new(
      {
        page: page,
        parent: parent,
        q: q,
        user_context: user_context
      }.merge(opts)
    )
  end
end
