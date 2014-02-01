# frozen_string_literal: true

module Philiprehberger
  module HtmlBuilder
    # HTML entity escaping utilities
    module Escape
      ENTITIES = {
        '&' => '&amp;',
        '<' => '&lt;',
        '>' => '&gt;',
        '"' => '&quot;',
        "'" => '&#39;'
      }.freeze

      ENTITY_PATTERN = Regexp.union(ENTITIES.keys).freeze

      # Escape HTML special characters in a string
      #
      # @param value [String] the string to escape
      # @return [String] the escaped string
      def self.html(value)
        value.to_s.gsub(ENTITY_PATTERN, ENTITIES)
      end
    end
  end
end
