# frozen_string_literal: true

require "json"
require "uri"

module Miteru
  class Feeds
    class PhishingDatabase < Feed
      URL = "https://raw.githubusercontent.com/mitchellkrogza/Phishing.Database/master/phishing-links-ACTIVE-NOW.txt"

      def urls
        body = get(URL)
        body.to_s.lines.map(&:chomp)
      rescue HTTPResponseError, HTTP::Error, JSON::ParserError => e
        info "Failed to load phishing database feed (#{e})"
        []
      end
    end
  end
end
