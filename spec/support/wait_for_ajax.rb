module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def wait_for_modal
    Timeout.timeout(Capybara.default_wait_time) do
      loop until modal_opened?
    end
  end

  def modal_opened?
    page.find('body')[:class].include?('modal-opened')
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
