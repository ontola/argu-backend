# frozen_string_literal: true
require 'test_helper'

class PhaseTest < ActiveSupport::TestCase
  define_freetown
  let(:project) { create(:project, parent: freetown.edge) }
  subject { create(:phase, id: 1, project: project, parent: project.edge) }
  let!(:next_phase) { create(:phase, id: 2, project: project, parent: project.edge) }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'update start_date of next phase' do
    subject
    project.phases.reload
    assert_equal subject, project.phases.first
    assert_equal next_phase, subject.next_phase
    assert_equal subject.end_date, nil
    assert_equal next_phase.start_date, nil

    project.update(start_date: DateTime.yesterday)
    subject.reload
    assert_equal subject.start_date, project.start_date,
                 'start date of first phase is not set to start date of project'

    subject.update(end_date: DateTime.tomorrow)
    project.phases.reload
    next_phase.reload
    assert_equal subject.end_date + 1.second, next_phase.start_date,
                 'start date of second phase is not set to end date of first phase'

    assert_not project.update(start_date: 1.month.from_now),
               'start date of project can be set after end date of first phase'

    next_phase.update(end_date: 2.days.from_now)
    subject.next_phase.reload
    assert_not subject.update(end_date: 1.month.from_now),
               'end date of first project can be set after end date of second phase'

    assert_not next_phase.update(end_date: DateTime.current),
               'end date of second phase can be set before end date of first phase'

    next_phase.update(end_date: 1.year.from_now)
    project.reload
    assert_equal next_phase.end_date.to_i, project.end_date.to_i,
                 'end date of project is not set to end date of last phase'
  end
end
