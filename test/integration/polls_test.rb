# frozen_string_literal: true

require 'test_helper'

class PollsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:staff) { create(:user, :staff) }
  let(:poll) { create(:poll, parent: freetown) }
  let!(:term1) { create(:term, parent: poll.options_vocab, title: 'Term1') }
  let!(:term2) { create(:term, parent: poll.options_vocab, title: 'Term2') }

  test 'staff should update poll' do
    sign_in staff

    assert_equal poll.options_vocab.terms.reorder(:position).all.map(&:display_name), %w[Term1 Term2]

    general_update(
      results: {should: true, response: :success},
      record: :poll,
      attributes: {
        options_vocab_attributes: {
          id: poll.options_vocab.id,
          terms_attributes: {
            3 => vote_options_attrs(nil, display_name: 'NewTerm', position: 1),
            2 => vote_options_attrs(term2.id, position: 2),
            1 => vote_options_attrs(term1.id, position: 3)
          }
        }
      },
      differences: [['Poll', 0], ['Vocabulary', 0], ['Term', 1]]
    )

    assert_equal poll.options_vocab.terms.reorder(:position).all.map(&:display_name), %w[NewTerm Term2 Term1]
    expect_triple(poll.options_vocab.iri, NS.sp.Variable, NS.sp.Variable, NS.ontola[:invalidate])
    assert_includes(rdf_body.subjects, term1.iri)
    assert_includes(rdf_body.subjects, Term.last.iri)
    assert_not_includes(rdf_body.subjects, term2.iri)
  end

  private

  def vote_options_attrs(id, **attrs)
    attrs[:id] = id if id
    attrs
  end
end
