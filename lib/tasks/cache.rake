# frozen_string_literal: true

namespace :cache do
  desc 'Refresh the cache'
  task :refresh => %w[clear warm]

  desc 'Sends the clear signal to the cache, ensure the worker is running'
  task clear: :environment do
    InvalidateCacheWorker.invalidate_all
  end

  desc 'Warms the cache by requesting all resources in the system'
  task warm: :environment do
    SLICE_SIZE = 20

    Apartment::Tenant.each do
      website = Page.find_via_shortname(Apartment::Tenant.current).iri.to_s
      Rails.logger.info("Collecting IRIs for website #{website}")
      iris = collect_iris

      puts "Warming up to #{iris.length} resources for website #{website} in #{(iris.length / SLICE_SIZE).ceil} steps"

      $stdout.write '['
      errors = bulk_request(iris, website)
      $stdout.write "]\n"

      warn "Errors while warming: #{errors.join("\n")}" if errors.present?
      puts 'Finished warming cache'
    end
  end
end

def static_iris
  [
    RDF::URI("https://argu.co/ns/core")
  ]
end

def dynamic_iris
  objects = Edge.all.flat_map { |o| traverse(o, o.class.show_includes, :show_includes) }
  objects
    .map { |o| o&.try(:iri) }
    .filter { |o| o.is_a?(RDF::URI) }
end

def collect_iris
  static_iris + dynamic_iris
end

def bulk_request(iris, website)
  iris.each_slice(SLICE_SIZE).flat_map do |resources|
    $stdout.write '*'
    party = bulk_request_batch(resources, website)

    $stdout.write "\b." if party.response.code == '200'

    if party.response.code != '200'
      $stdout.write "\be"
      "Received status #{party.response.code} on resources [#{resources.join(', ')}]"
    end
  end
end

def bulk_request_batch(resources, website)
  url = 'http://apex_rs.svc.cluster.local:3030/link-lib/bulk'
  opts = {
    body: {resource: resources},
    headers: {
      'Accept-Language': 'en',
      'Website-IRI': website,
      'X-Forwarded-Host': URI(website).host,
      'X-Forwarded-Proto': 'https'
    }
  }

  HTTParty.post(url, opts)
end

def traverse(obj, include, deep_includes = nil)
  return unless obj

  result = resolve_value(obj, include, deep_includes)
  nested = resolve_collection_value(obj, include, deep_includes)

  [
    obj,
    result,
    nested
  ].flatten.compact.uniq
end

def resolve_value(obj, include, deep_includes) # rubocop:disable Metrics/MethodLength
  if include.is_a?(Symbol) || include.is_a?(String)
    resolve_path(obj, include)
  elsif include.is_a?(Array)
    resolve_array(obj, include, deep_includes)
  elsif include.is_a?(Hash)
    resolve_hash(obj, include, deep_includes)
  elsif include.nil?
    nil
  else
    throw "Unexpected include type '#{include.class.name}' (value was: #{include})"
  end
end

def resolve_array(obj, include, deep_includes)
  include.uniq.flat_map do |i|
    include_map = deep_includes ? i.class.try(deep_includes) : i
    traverse(obj, include_map || i)
  end
end

def resolve_hash(obj, include, deep_includes)
  include.flat_map do |k, v|
    nested_obj = obj.try(k)
    include_map = deep_includes ? nested_obj.class.try(deep_includes) : v
    traverse(nested_obj, include_map || v)
  rescue StandardError => e
    warn "Caught error: #{e}"
  end
end

def resolve_path(obj, include)
  include.to_s.split('.').reduce([obj]) { |objs, prop| objs + [objs.try(prop)] }
rescue StandardError => e
  warn "Caught error: #{e}, include: #{include.class.name}(#{include})"
end

def resolve_collection_value(obj, include, deep_includes)
  return unless obj.is_a?(Collection)

  obj.parent.send(obj.association).all.flat_map do |member|
    include_map = deep_includes ? member.class.try(deep_includes) : include
    traverse(member, include_map || include)
  end
rescue StandardError => e
  warn "Caught error: #{e}"
end
