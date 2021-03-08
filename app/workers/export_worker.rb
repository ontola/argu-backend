# frozen_string_literal: true

require 'zip'

HIERARCHY = %i[forums questions motions pro_arguments con_arguments comments].freeze

class ExportWorker # rubocop:disable Metrics/ClassLength
  include Sidekiq::Worker
  include StatisticsHelper

  attr_accessor :export

  def perform(export_id) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    self.export = Export.find_by(id: export_id)
    return if export.blank?

    export.processing!
    ActsAsTenant.with_tenant(export.edge.root) do
      generate_zip
    end
    export.done!
  rescue StandardError => e
    Bugsnag.notify(e)
    export.failed!
  ensure
    DataEvent.publish(export) if export.present?
  end

  private

  def add_json(zip)
    json = data.map do |type, records|
      [
        type,
        records.map { |record| json_for(record) }
      ]
    end
    zip.get_output_stream('data.json') { |f| f.write(Oj.dump(Hash[json], mode: :compat)) }
  end

  def add_triple_formats(zip)
    %i[n3 ntriples jsonld rdfxml hndjson].map do |format|
      zip.get_output_stream("data.#{format}") do |f|
        data.each do |_type, records|
          records.each do |record|
            f.write(serializer_for(record).dump(format))
          end
        end
      end
    end
  end

  def add_xls(zip)
    book = Spreadsheet::Workbook.new
    populate_overview(book)
    populate_class_sheets(book)
    zip.get_output_stream('data.xls') { |f| book.write(f) }
  end

  def data
    @data ||=
      export
        .edge
        .self_and_descendants
        .includes(:activities, :parent)
        .flat_map(&method(:relations))
        .group_by { |m| m.class.name }
  end

  def format_value_xls(value) # rubocop:disable Metrics/MethodLength
    case value
    when Array
      value.map { |v| format_value_xls(v) }.join(', ')
    when Hash
      if value[:type] == NS::ONTOLA[:Collection]
        value[:totalCount]
      elsif value[:iri].present?
        Spreadsheet::Link.new(value[:iri].to_s)
      end
    when RDF::URI, RDF::DynamicURI
      Spreadsheet::Link.new(value.to_s)
    else
      value
    end
  end

  def populate_class_sheets(book) # rubocop:disable Metrics/AbcSize
    data.each do |type, records|
      sheet = book.create_worksheet(name: I18n.t("#{type.tableize}.plural"))
      records.each_with_index do |record, index|
        json = json_for(record)
        sheet.row(0).replace(json.keys.map { |key| key.to_s.gsub('Collection', 'Count') }) if index.zero?
        sheet.row(index + 1).replace(json.values.map { |value| format_value_xls(value) })
      end
    end
  end

  def populate_overview(book)
    overview = book.create_worksheet(name: I18n.t('exports.formats.xls.overview_title'))
    overview.row(0).replace(overview_header)
    overview.row(0).default_format = Spreadsheet::Format.new(size: 12, weight: :bold, pattern_bg_color: :red)
    overview.freeze!(1, 0)
    overview_item(overview, export.edge)
  end

  def overview_header
    overview_prefix_titles.concat(HIERARCHY.map do |c|
      [
        I18n.t('exports.formats.xls.title', type: I18n.t("#{c}.type")),
        I18n.t('exports.formats.xls.description', type: I18n.t("#{c}.type"))
      ]
    end).flatten
  end

  def overview_item(sheet, record)
    hierarchy_depth = HIERARCHY.index(record.class_name.to_sym)

    overview_item_row(sheet, record, hierarchy_depth) if hierarchy_depth.present?

    HIERARCHY[(hierarchy_depth || -1) + 1..-1].reverse.each do |child_type|
      (record.try(child_type) || []).each { |child| overview_item(sheet, child) }
    end
  end

  def overview_item_row(sheet, record, hierarchy_depth)
    data = [record.display_name, record.description]
    indent = hierarchy_depth * data.length

    sheet << overview_prefix_columns(record) + Array.new(indent) + data
    sheet.last_row.default_format = Spreadsheet::Format.new(text_wrap: true)
    sheet.last_row.outline_level = hierarchy_depth
  end

  def overview_prefix_titles
    [
      I18n.t('exports.formats.xls.path'),
      I18n.t('formtastic.labels.url'),
      I18n.t('retracted'),
      I18n.t('statistics.users_count.label'),
      I18n.t('statistics.contributions_count.label'),
      I18n.t('tooltips.motion.vote_pro_count'),
      I18n.t('tooltips.motion.vote_neutral_count'),
      I18n.t('tooltips.motion.vote_con_count')
    ]
  end

  def overview_prefix_columns(record) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    measures = build_observation_measures(record)

    [
      record.path,
      record.iri.to_s,
      retracted_label(record),
      measures[NS::ARGU[:usersCount]],
      measures[NS::ARGU[:contributionsCount]],
      record.try(:default_vote_event)&.children_count(:votes_pro),
      record.try(:default_vote_event)&.children_count(:votes_neutral),
      record.try(:default_vote_event)&.children_count(:votes_con)
    ]
  end

  def generate_zip
    filename = Rails.root.join('tmp/argu-data-export.zip')
    Zip::File.open(filename, Zip::File::CREATE) do |zip|
      add_xls(zip)
      add_json(zip)
      add_triple_formats(zip)
    end
    export.update!(zip: File.open(filename))
    File.delete(filename)
  end

  def json_for(record)
    json_api = serializer_for(record).serializable_hash
    json_api[:data][:attributes].merge(json_api[:data][:relationships])
  end

  def relations(edge)
    [
      edge,
      edge.try(:default_profile_photo),
      edge.try(:media_objects).try(:to_a),
      edge.try(:placements).try(:to_a)
    ].flatten.compact
  end

  def retracted_label(record)
    return unless record.is_trashed? || !record.is_published?

    record.is_trashed? ? I18n.t('trashed') : I18n.t('draft')
  end

  def scope
    @scope ||= UserContext.new(user: export.user, doorkeeper_scopes: %w[export])
  end

  def serializer_for(record)
    RDF::Serializers.serializer_for(record)&.new(record, params: {scope: scope})
  end
end
