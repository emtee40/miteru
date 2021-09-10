# frozen_string_literal: true

require "json"
require "uri"

module Miteru
  class Feeds
    class Ayashige < Feed
      HOST = "ayashige.herokuapp.com"
      URL = "https://#{HOST}"

      def urls
        url = url_for("/api/v1/domains/")
        res = JSON.parse(get(url))

        domains = res.map { |item| item["fqdn"] }
        domains.map do |domain|
          [
            "https://#{domain}",
            "http://#{domain}"
          ]
        end.flatten
      rescue HTTPResponseError, HTTP::Error, JSON::ParserError => e
        puts "Failed to load ayashige feed (#{e})"
        []
      end

      private

      def url_for(path)
        URI(URL + path)
      end
    end
  end
end
