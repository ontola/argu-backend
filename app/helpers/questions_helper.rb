module QuestionsHelper
  include DropdownHelper

  def question_items(question)
    link_items = []
    if policy(question).update?
      link_items << link_item(t('edit'), edit_question_path(question), fa: 'pencil')
    end
    if policy(QuestionAnswer).new?
      link_items << link_item(t('question_answers.couple_motion'),
                              new_question_answer_url(question_answer: {question_id: question}),
                              fa: 'link')
    end
    if policy(question).trash?
      link_items << link_item(t('trash'),
                              question_path(question),
                              data: {
                                  confirm: t('trash_confirmation'),
                                  method: 'delete',
                                  'skip-pjax' => 'true'},
                              fa: 'trash')
    end
    if policy(question).destroy?
      link_items << link_item(t('destroy'),
                              question_path(question, destroy: true),
                              data: {
                                  confirm: t('destroy_confirmation'),
                                  method: 'delete',
                                  'skip-pjax' => 'true'},
                              fa: 'close')
    end
    dropdown_options(t('menu'),
                     [{items: link_items}],
                     fa: 'fa-gear')
  end
end
