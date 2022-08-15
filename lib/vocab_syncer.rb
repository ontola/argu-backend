# frozen_string_literal: true

class VocabSyncer # rubocop:disable Metrics/ClassLength
  extend URITemplateHelper

  HASH_KEY = 'argu.seeds.vocabularies.hash'

  class << self
    def new_version
      version = current_hash
      version if version != stored_hash
    end

    def store_version(version)
      Argu::Redis.set(hash_key, version)
    end

    def sync(url)
      vocab = find_vocab(url)

      unless vocab.system
        Rails.logger.info("Skipping #{url} for #{ActsAsTenant.current_tenant.iri_prefix} because it is overwritten")
        return
      end

      update_vocab(vocab)
      update_terms(vocab)
    end

    def sync_all
      if new_version
        Rails.logger.info('Syncing vocabularies')

        sync_all!

        store_version(new_version)
      else
        Rails.logger.info('Vocabularies did not change')
      end
    end

    def sync_all!
      Page.find_each do |page|
        ActsAsTenant.with_tenant(page) do
          VocabSyncWorker.perform_async
        end
      end
    end

    def sync_page
      I18n.locale = ActsAsTenant.current_tenant.language

      Searchkick.disable_callbacks
      RequestStore.store[:disable_broadcast] = true

      I18n.t('vocabularies.system').each_key do |key|
        VocabSyncer.sync(key.to_s.camelize(:lower))
      end
    ensure
      Searchkick.enable_callbacks
      RequestStore.store[:disable_broadcast] = false
    end

    private

    def cleanup_terms(current_terms, term_options)
      exact_matches = term_options.map { |options| options[:exact_match] }.compact
      raise('No exact matches defined') if exact_matches.blank?

      current_terms
        .reject { |term| term.trashed_at.present? || exact_matches.include?(term.exact_match) }
        .each { |term| term.update(trashed_at: Time.current) }
    end

    def current_hash
      @current_hash ||=
        file_hash('config/locales/nl/system_vocabularies.nl.yml') +
        file_hash('config/locales/en/system_vocabularies.en.yml') +
        file_hash('config/locales/de/system_vocabularies.de.yml')
    end

    def file_hash(file_name)
      Digest::MD5.file(file_name).hexdigest
    end

    def find_term(vocab, current_terms, exact_match, index) # rubocop:disable Metrics/MethodLength
      existing = current_terms.detect { |term| term.exact_match == exact_match }
      return existing if existing

      Term.create!(
        active_branch: true,
        creator: ActsAsTenant.current_tenant.profile,
        display_name: exact_match,
        exact_match: exact_match,
        is_published: true,
        parent: vocab,
        position: index + 1,
        publisher: ActsAsTenant.current_tenant.publisher
      )
    end

    def find_vocab(url) # rubocop:disable Metrics/MethodLength
      existing = Vocabulary.find_via_shortname(url)
      return existing if existing

      Vocabulary.create!(
        active_branch: true,
        creator: ActsAsTenant.current_tenant.profile,
        display_name: url,
        initial_public_grant: 'spectator',
        is_published: true,
        parent: ActsAsTenant.current_tenant,
        publisher: ActsAsTenant.current_tenant.publisher,
        system: true,
        url: url
      )
    end

    def hash_key
      "#{HASH_KEY}.argu"
    end

    def stored_hash
      Argu::Redis.get(hash_key)
    end

    def update_terms(vocab)
      term_options = I18n.t("vocabularies.system.#{vocab.url.underscore}.terms")
      terms = vocab.terms.preload(:publisher, :creator, :shortname)
      cleanup_terms(terms, term_options)

      term_options.each_with_index do |opts, index|
        term = find_term(vocab, terms, opts[:exact_match], index)
        update_term(term, opts, index)
      end
    end

    def update_term(term, options, index)
      term.assign_attributes(
        color: options[:color],
        description: options[:description],
        display_name: options[:label],
        icon: font_awesome_iri("fa-#{options[:icon]}"),
        position: index + 1
      )

      term.save! if term.changed?
    end

    def update_vocab(vocab)
      vocab.assign_attributes(
        description: I18n.t("vocabularies.system.#{vocab.url.underscore}.description", default: nil),
        display_name: I18n.t("vocabularies.system.#{vocab.url.underscore}.label"),
        tagged_label: I18n.t("vocabularies.system.#{vocab.url.underscore}.tagged_label", default: nil)
      )

      vocab.save! if vocab.changed?
    end
  end
end
