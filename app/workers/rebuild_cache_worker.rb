# frozen_string_literal: true

class RebuildCacheWorker
  include Sidekiq::Worker

  def perform(version)
    raise "Trying to build cache for version #{version}" if version != VERSION
    return unless create_version_directory

    Apartment::Tenant.each do
      Page.find_each do |page|
        ActsAsTenant.with_tenant(page) do
          Edge.includes(:publisher, :creator, :parent, :root, :shortname).find_each do |edge|
            worker = BroadcastWorker.new
            worker.resource = edge
            worker.write_nquads
          end
        end
      end
    end
  end

  private

  def cache_dir
    ENV['CACHE_DIRECTORY']
  end

  def create_version_directory
    return if cache_dir.blank?

    FileUtils.mkdir_p(cache_dir)
    FileUtils.mkdir(version_directory)

    File.delete(latest_directory) if File.symlink?(latest_directory)
    File.symlink(version_directory, latest_directory)

    true
  rescue Errno::EEXIST
    false
  end

  def latest_directory
    Rails.root.join(cache_dir, 'latest')
  end

  def version_directory
    Rails.root.join(cache_dir, VERSION)
  end
end
