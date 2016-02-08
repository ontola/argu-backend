module QuestionsHelper
  include DropdownHelper

  def question_items(question)
    link_items = []
    if policy(QuestionAnswer).new?
      link_items << link_item(t('question_answers.couple_motion'),
                              new_question_answer_url(question_answer: {question_id: question}),
                              fa: 'link')
    end
    link_items
  end
end
