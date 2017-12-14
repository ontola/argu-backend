# frozen_string_literal: true

RSpec.shared_examples_for 'requests' do |opts = {skip: []}|
  opts[:skip] ||= []

  it_behaves_like 'get new', opts.merge(formats: new_formats) unless opts[:skip].include?(:new)
  it_behaves_like 'get edit', opts.merge(formats: edit_formats) unless opts[:skip].include?(:edit)
  it_behaves_like 'get delete', opts.merge(formats: delete_formats) unless opts[:skip].include?(:delete)
  it_behaves_like 'get shift', opts.merge(formats: shift_formats) if opts[:move]
  it_behaves_like 'get show', opts.merge(formats: show_formats) unless opts[:skip].include?(:show)
  it_behaves_like 'post create', opts.merge(formats: create_formats) unless opts[:skip].include?(:create)
  it_behaves_like 'get index', opts.merge(formats: index_formats) unless opts[:skip].include?(:index)
  it_behaves_like 'delete destroy', opts.merge(formats: destroy_formats) unless opts[:skip].include?(:destroy)
  it_behaves_like 'delete trash', opts.merge(formats: trash_formats) unless opts[:skip].include?(:trash)
  it_behaves_like 'put untrash', opts.merge(formats: untrash_formats) unless opts[:skip].include?(:untrash)
  it_behaves_like 'put update', opts.merge(formats: update_formats) unless opts[:skip].include?(:update)
  it_behaves_like 'put move', opts.merge(formats: move_formats) if opts[:move]
end
