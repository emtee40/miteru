# frozen_string_literal: true

require "colorize"
require "parallel"
require "uri"

module Miteru
  class Crawler
    attr_reader :downloader, :feeds

    def initialize
      @downloader = Downloader.new(Miteru.configuration.download_to)
      @feeds = Feeds.new
      @notifier = Notifier.new
    end

    def crawl(entry)
      website = Website.new(entry.url, entry.source)
      downloader.download_kits(website.kits) if website.has_kits? && auto_download?
      notify(website) if website.has_kits? || verbose?
    rescue OpenSSL::SSL::SSLError, HTTP::Error, Addressable::URI::InvalidURIError => _e
      nil
    end

    def execute
      suspicious_entries = feeds.suspicious_entries
      puts "Loaded #{suspicious_entries.length} URLs to crawl. (crawling in #{threads} threads)" if verbose?

      Parallel.each(suspicious_entries, in_threads: threads) do |entry|
        crawl entry
      end
    end

    def threads
      @threads ||= Miteru.configuration.threads
    end

    def notify(website)
      @notifier.notify(url: website.url, kits: website.kits, message: website.message)
    end

    def auto_download?
      Miteru.configuration.auto_download?
    end

    def verbose?
      Miteru.configuration.verbose?
    end

    class << self
      def execute
        new.execute
      end
    end
  end
end
