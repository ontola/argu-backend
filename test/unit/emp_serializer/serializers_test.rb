# frozen_string_literal: true

require 'unit_test_helper'

class SerializersTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
  include FactoryBot::Syntax::Methods
  include Argu::TestHelpers::SliceHelperMethods

  let(:forum) { build(:forum, :with_iri, parent: build(:page)) }
  let(:motion) { build(:motion, :with_iri, parent: forum) }
  let(:comment) { build(:comment, :with_iri, parent: motion) }
  let(:orphan_comment) { build(:comment, :with_iri) }
  let(:blank_comment) { build(:comment, parent: motion) }
  let(:blank_orphan_comment) { build(:comment) }
  let(:sequence_iri) { LinkedRails.iri(path: 'seq') }
  let(:comment_collection) { Comment.root_collection }
  let(:data_set_iri) { LinkedRails.iri(path: 'data_set') }

  test 'serializes belongs to reference' do
    serialize_emp_json_hash(comment)

    expect_slice_subjects(@emp_json_hash, comment)
    expect_slice_attribute(@emp_json_hash, comment, :isPartOf, motion.iri)
  end

  test 'serializes included belongs to resource' do
    serialize_emp_json_hash(comment, include: %i[parent])

    expect_slice_subjects(@emp_json_hash, comment, motion)
    expect_slice_attribute(@emp_json_hash, comment, :isPartOf, motion.iri)
  end

  test 'ignores nil belongs to' do
    serialize_emp_json_hash(orphan_comment)

    expect_slice_subjects(@emp_json_hash, orphan_comment)
    expect_slice_attribute(@emp_json_hash, orphan_comment, :isPartOf, nil)
  end

  test 'serializes has_many' do
    data_set = DataCube::Set.new(
      iri: data_set_iri,
      dimensions: [NS.schema.about],
      measures: [NS.schema.name],
      observations: [
        {dimensions: {NS.schema.about => 'about1'}, measures: {NS.schema.name => 'name1'}},
        {dimensions: {NS.schema.about => 'about2'}, measures: {NS.schema.name => 'name2'}}
      ]
    )

    serialize_emp_json_hash(data_set)

    assert_equal(values_from_slice(@emp_json_hash, data_set_iri, 'observation').count, 2)
  end

  test 'serializes multiple comments' do
    serialize_emp_json_hash([comment, orphan_comment])

    expect_slice_subjects(@emp_json_hash, comment, orphan_comment)
    expect_slice_attribute(@emp_json_hash, comment, :type, Comment.iri)
    expect_slice_attribute(@emp_json_hash, orphan_comment, :type, Comment.iri)
  end

  test 'serializes sequence of comments' do
    serialize_emp_json_hash(
      LinkedRails::Sequence.new(
        [comment, orphan_comment],
        id: sequence_iri,
        scope: false
      )
    )

    expect_slice_subjects(@emp_json_hash, sequence_iri)
    expect_slice_attribute(@emp_json_hash, sequence_iri, '0', comment.iri)
    expect_slice_attribute(@emp_json_hash, sequence_iri, '1', orphan_comment.iri)
  end

  test 'serializes sequence of blank comments' do
    serialize_emp_json_hash(
      LinkedRails::Sequence.new(
        [blank_comment, blank_orphan_comment],
        id: sequence_iri,
        scope: false
      )
    )

    expect_slice_subjects(@emp_json_hash, sequence_iri, blank_comment, blank_orphan_comment)
    expect_slice_attribute(@emp_json_hash, sequence_iri, '0', blank_comment.iri)
    expect_slice_attribute(@emp_json_hash, sequence_iri, '1', blank_orphan_comment.iri)
  end

  test 'serializes list of literals' do
    list = RDF::List['one', 'two']
    serialize_emp_json_hash(list)

    expect_slice_subjects(@emp_json_hash, list.subject, partial_match: true)
    expect_slice_attribute(@emp_json_hash, list.subject, :type, RDF.List)
    list_attrs = @emp_json_hash[list.subject.to_s]
    assert_equal(list_attrs['first'], primitive_to_value('one'))
    assert_equal(@emp_json_hash[list_attrs['rest'][:v]]['first'], primitive_to_value('two'))
  end

  test 'serializes list of comments' do
    list = RDF::List[comment.iri, orphan_comment.iri]
    serialize_emp_json_hash(list)

    expect_slice_subjects(@emp_json_hash, list.subject, partial_match: true)
    expect_slice_attribute(@emp_json_hash, list.subject, :type, RDF.List)
    list_attrs = @emp_json_hash[list.subject.to_s]
    assert_equal(list_attrs['first'], primitive_to_value(comment.iri))
    assert_equal(@emp_json_hash[list_attrs['rest'][:v]]['first'], primitive_to_value(orphan_comment.iri))
  end

  test 'serializes mixed models' do
    assert_raises 'Trying to serialize mixed resources' do
      serialize_emp_json_hash([comment, motion])
    end
  end

  test 'serializes a collection' do
    serialize_emp_json_hash(comment_collection)

    expect_slice_subjects(@emp_json_hash, comment_collection, partial_match: true)
    expect_slice_subjects(@emp_json_hash, *comment_collection.sortings, partial_match: true)
    expect_slice_subjects(@emp_json_hash, *comment_collection.filter_fields, partial_match: true)

    expect_slice_attribute(@emp_json_hash, comment_collection, :createAction, comment_collection.action(:create).iri)
  end

  test 'serializes a collection page' do
    serialize_emp_json_hash(comment_collection.default_view)

    expect_slice_subjects(@emp_json_hash, comment_collection.default_view, comment_collection.default_view.members_iri)
  end

  test 'serializes a form' do
    serialize_emp_json_hash(MotionForm.new)

    pages = values_from_slice(@emp_json_hash, MotionForm.form_iri.value, 'pages')[:v]
    page = values_from_slice(@emp_json_hash, pages, '0')[:v]
    expect_slice_attribute(@emp_json_hash, page, 'type', NS.form[:Page])
  end

  private

  def serialize_emp_json_hash(resource = nil, options = {})
    default_options = {symbolize: true}

    @emp_json_hash =
      RDF::Serializers
        .serializer_for(resource)
        .new(resource, RDF::Serializers::Renderers.transform_opts(default_options.merge(options), {}))
        .emp_json_hash
  end
end
