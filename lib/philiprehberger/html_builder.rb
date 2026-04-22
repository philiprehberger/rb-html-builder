# frozen_string_literal: true

require_relative 'html_builder/version'
require_relative 'html_builder/escape'
require_relative 'html_builder/node'
require_relative 'html_builder/builder'

module Philiprehberger
  module HtmlBuilder
    class Error < StandardError; end

    # Build HTML using a tag DSL (minified output)
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

    # Build pretty-printed HTML using a tag DSL
    #
    # @param indent_size [Integer] number of spaces per indent level (default 2)
    # @yield [Builder] the builder instance for DSL evaluation
    # @return [String] the pretty-printed HTML string
    # @raise [Error] if no block is given
    def self.build_pretty(indent_size: 2, &block)
      raise Error, 'a block is required' unless block

      builder = Builder.new
      builder.instance_eval(&block)
      builder.to_pretty_html(indent_size: indent_size)
    end

    # Build minified HTML (alias for build)
    #
    # @yield [Builder] the builder instance for DSL evaluation
    # @return [String] the rendered HTML string
    # @raise [Error] if no block is given
    def self.build_minified(&)
      build(&)
    end

    # Build a full HTML5 document: emits `<!DOCTYPE html>` followed by the
    # rendered block, separated by a newline.
    #
    # The block is evaluated at the root level exactly like `.build` / `.build_pretty`,
    # so the caller decides whether to add an `<html>` wrapper. When `pretty: true`,
    # output is pretty-printed with the given indent size.
    #
    # @param pretty [Boolean] whether to pretty-print the block output (default false)
    # @param indent_size [Integer] number of spaces per indent level when pretty (default 2)
    # @yield [Builder] the builder instance for DSL evaluation
    # @return [String] the rendered HTML document string
    # @raise [Error] if no block is given
    def self.document(pretty: false, indent_size: 2, &block)
      raise Error, 'a block is required' unless block

      builder = Builder.new
      builder.instance_eval(&block)
      body = pretty ? builder.to_pretty_html(indent_size: indent_size) : builder.to_html
      "#{DoctypeNode::DECLARATION}\n#{body}"
    end

    # Merge multiple HTML fragment strings into one
    #
    # @param fragments [Array<String>] HTML fragments to merge
    # @return [String] the merged HTML string
    def self.merge(*fragments)
      fragments.join
    end

    # Escape HTML special characters in a string using the same escaper as the DSL.
    #
    # @param value [Object] the value to escape (converted to string)
    # @return [String] the escaped string
    def self.escape(value)
      Escape.html(value)
    end
  end
end
