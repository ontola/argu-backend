# frozen_string_literal: true

RSpec.shared_examples_for 'requests' do |opts = {skip: []}|
  def self.excluded?(opts, format, method)
    opts[:skip].include?(method) || opts[:skip].include?("#{format}_#{method}".to_sym)
  end

  opts[:skip] ||= []
  unless opts[:skip].include?(:html)
    it_behaves_like 'get new', opts unless excluded?(opts, nil, :new)
    it_behaves_like 'get edit', opts unless excluded?(opts, nil, :edit)
    it_behaves_like 'get delete', opts unless excluded?(opts, nil, :delete)
    it_behaves_like 'get shift', opts if opts[:move]
  end

  (%i[html json_api nt] - opts[:skip]).each do |format|
    context "as #{format}" do
      let(:request_format) { format }
      it_behaves_like 'get show', opts unless excluded?(opts, format, :show)
      it_behaves_like 'post create', opts unless excluded?(opts, format, :create)
      it_behaves_like 'get index', opts unless excluded?(opts, format, :index)
      it_behaves_like 'delete destroy', opts unless excluded?(opts, format, :destroy)
      it_behaves_like 'delete trash', opts unless excluded?(opts, format, :trash)
      it_behaves_like 'put untrash', opts unless excluded?(opts, format, :untrash)
      it_behaves_like 'put update', opts unless excluded?(opts, format, :update)
      it_behaves_like 'put move', opts if opts[:move]
    end
  end
end
