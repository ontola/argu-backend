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
    Thread.current[:mock_searchkick] = false
    ActsAsTenant.current_tenant = argu
    Edge.reindex_with_tenant(async: false)
  end

  after do
    Thread.current[:mock_searchkick] = true
  end

  describe 'scoping' do
    context 'as user' do
      it { expect(search_result.total_count).to eq(4) }
    end

    context 'as admin' do
      let(:user) { create_administrator(argu) }

      it { expect(search_result.total_count).to eq(8) }
    end

    it { expect(search_result(parent: unpublished_question).total_count).to eq(0) }
  end

  describe 'pagination' do
    it { expect(search_result.total_count).to eq(4) }
    it { expect(search_result(page_size: 3).search_result.count).to eq(3) }
    it { expect(search_result(page_size: 3, page: 2).search_result.count).to eq(1) }
  end

  describe 'search in branch' do
    it { expect(search_result(parent: question).total_count).to eq(1) }
    it { expect(search_result(parent: motion).total_count).to eq(1) }
    it { expect(search_result(parent: argument).total_count).to eq(0) }
  end

  describe 'keeping index up to date' do
    it 'keeps trashed items in index' do
      expect(search_result.search_result.count).to eq(4)
      motion.trash
      expect(search_result.search_result.count).to eq(4)
    end

    it 'remove destroyed items from index' do
      expect(search_result.search_result.count).to eq(4)
      motion.destroy
      expect(search_result.search_result.count).to eq(3)
      expect(search_result.search_result.reject(&:is_published?)).to be_empty
    end

    it 'updates a record' do
      wait_for_count(question.display_name, 1)
      wait_for_count('New_name', 0)
      Sidekiq::Testing.inline! do
        question.update!(display_name: 'New_name')
      end
      wait_for_count(question.display_name, 0)
      wait_for_count('New_name', 1)
    end
  end

  describe 'reindex with tenant' do
    it 'reindexes a record' do
      wait_for_count(question.display_name, 1)
      wait_for_count('New_name', 0)
      Sidekiq::Testing.inline! do
        question.property_manager(NS::SCHEMA[:name]).send(:properties).first.update!(string: 'New_name')
      end
      wait_for_count(question.display_name, 1)
      wait_for_count('New_name', 0)
      Sidekiq::Testing.inline! do
        Page.reindex_with_tenant
      end
      wait_for_count('New_name', 1)
      wait_for_count(question.display_name, 0)
    end
  end

  private

  def search_result(opts = {})
    SearchResult.new(
      {
        page: page,
        parent: parent,
        q: q,
        user_context: user_context
      }.merge(opts)
    )
  end

  def wait_for_count(query, count)
    Timeout.timeout(5, Timeout::Error, "Expecting #{count} results for #{q}") do
      sleep(0.1) until search_result(q: query).total_count == count
    end
  end
end
