# frozen_string_literal: true
module QuestionsHelper
  include DropdownHelper

  def question_items(question)
    link_items = []
    if policy(question).create_child?(:question_answers, question: question)
      link_items << link_item(t('question_answers.couple_motion'),
                              new_question_answer_url(question_answer: {question_id: question}),
                              fa: 'link')
    end
    link_items
  end
end
