# frozen_string_literal: true

require_relative 'html_builder/version'
require_relative 'html_builder/escape'
require_relative 'html_builder/node'
require_relative 'html_builder/builder'

module Philiprehberger
  module HtmlBuilder
    class Error < StandardError; end

    # Build HTML using a tag DSL
    #
    # @yield [Builder] the builder instance for DSL evaluation
    # @return [String] the rendered HTML string
    # @raise [Error] if no block is given
    def self.build(&block)
      raise Error, 'a block is required' unless block

      builder = Builder.new
      builder.instance_eval(&block)
      builder.to_html
    end
  end
end
