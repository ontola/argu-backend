# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Arguments', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    super - %i[html]
  end
  let(:class_sym) { :argument }
  let(:table_sym) { :arguments }
  let(:create_path) { url_for([subject.parent_model, :arguments, only_path: true]) }
  let(:index_path) { url_for([subject.parent_model, :pro_arguments, only_path: true]) }
  let(:non_existing_index_path) do
    url_for([parent_class_sym, :pro_arguments, "#{parent_class_sym}_id".to_sym => -1, only_path: true])
  end
  let(:non_existing_edit_path) { url_for([:edit, :pro_argument, id: -1, only_path: true]) }
  let(:non_existing_update_path) { url_for([:pro_argument, id: -1, only_path: true]) }
  let(:non_existing_delete_path) { url_for([:delete, :pro_argument, id: -1, only_path: true]) }
  let(:non_existing_destroy_path) { url_for([:pro_argument, id: -1, destroy: true, only_path: true]) }
  let(:non_existing_trash_path) { url_for([:pro_argument, id: -1, only_path: true]) }
  let(:non_existing_untrash_path) { url_for([:untrash, :pro_argument, id: -1, only_path: true]) }
  let(:created_resource_path) { url_for(subject.parent_model) }

  context 'with motion parent' do
    subject { argument }
    it_behaves_like 'requests'
  end

  context 'with linked record parent' do
    subject { linked_record_argument }
    let(:parent_path) {}
    let(:create_path) do
      linked_record_arguments_path(
        organization: argu.url,
        forum: freetown.url,
        linked_record_id: linked_record.deku_id
      )
    end
    let(:non_existing_create_path) do
      linked_record_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: -1)
    end
    let(:index_path) do
      linked_record_pro_arguments_path(
        organization: argu.url,
        forum: freetown.url,
        linked_record_id: linked_record.deku_id
      )
    end
    let(:non_existing_index_path) do
      linked_record_pro_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: -1)
    end
    it_behaves_like 'requests', skip: %i[new html]
  end

  context 'with non-persisted linked_record parent' do
    let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(freetown.page.url, freetown.url, SecureRandom.uuid) }
    subject do
      build(:argument, edge: Edge.new(parent: non_persisted_linked_record.edge))
    end
    let(:parent_path) {}
    let(:create_path) do
      linked_record_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: SecureRandom.uuid)
    end
    let(:non_existing_create_path) do
      linked_record_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: -1)
    end
    let(:index_path) do
      linked_record_pro_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: SecureRandom.uuid)
    end
    let(:non_existing_index_path) do
      linked_record_pro_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: -1)
    end
    it_behaves_like 'post create', skip: %i[html]
    it_behaves_like 'get index', skip: %i[html]
  end
end
