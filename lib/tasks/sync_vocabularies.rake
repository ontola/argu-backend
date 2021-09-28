# frozen_string_literal: true

Rake::Task['db:migrate'].enhance do
  Apartment::Tenant.each do
    VocabSyncer.sync_all
  end
end
