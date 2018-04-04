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
    url_for([parent_class_sym, :pro_arguments, "#{parent_class_sym}_id".to_sym => -99, only_path: true])
  end
  let(:non_existing_edit_path) { url_for([:edit, :pro_argument, id: -99, only_path: true]) }
  let(:non_existing_update_path) { url_for([:pro_argument, id: -99, only_path: true]) }
  let(:non_existing_delete_path) { url_for([:delete, :pro_argument, id: -99, only_path: true]) }
  let(:non_existing_destroy_path) { url_for([:pro_argument, id: -99, destroy: true, only_path: true]) }
  let(:non_existing_trash_path) { url_for([:pro_argument, id: -99, only_path: true]) }
  let(:non_existing_untrash_path) { url_for([:untrash, :pro_argument, id: -99, only_path: true]) }
  let(:created_resource_path) { url_for(subject.parent_model) }
  let(:update_params) { {pro_argument: Hash[required_keys.map { |k| [k, '12345'] }]} }
  let(:invalid_update_params) { {pro_argument: Hash[required_keys.map { |k| [k, '1'] }]} }
  let(:expect_put_update_html) do
    expect(response).to redirect_to(updated_resource_path)
    subject.reload
    update_params[:pro_argument].each { |k, v| expect(subject.send(k)).to eq(v) }
  end
  let(:expect_put_update_failed_html) do
    expect_success
    invalid_update_params[:pro_argument].each_value { |v| expect(response.body).to(include(v)) }
  end

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
      linked_record_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: -99)
    end
    let(:index_path) do
      linked_record_pro_arguments_path(
        organization: argu.url,
        forum: freetown.url,
        linked_record_id: linked_record.deku_id
      )
    end
    let(:non_existing_index_path) do
      linked_record_pro_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: -99)
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
      linked_record_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: -99)
    end
    let(:index_path) do
      linked_record_pro_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: SecureRandom.uuid)
    end
    let(:non_existing_index_path) do
      linked_record_pro_arguments_path(organization: argu.url, forum: freetown.url, linked_record_id: -99)
    end
    it_behaves_like 'post create', skip: %i[html]
    it_behaves_like 'get index', skip: %i[html]
  end
end
