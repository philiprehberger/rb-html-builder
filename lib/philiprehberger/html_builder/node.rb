# frozen_string_literal: true

module Philiprehberger
  module HtmlBuilder
    # Represents an HTML element node with tag, attributes, and children
    class Node
      # @return [Symbol] the tag name
      attr_reader :tag

      # @return [Hash] the element attributes
      attr_reader :attributes

      # @return [Array] the child nodes
      attr_reader :children

      # @param tag [Symbol] the HTML tag name
      # @param attributes [Hash] HTML attributes
      def initialize(tag, attributes: {})
        @tag = tag
        @attributes = attributes
        @children = []
      end

      # Add a child node
      #
      # @param child [Node, String] child node or text content
      # @return [void]
      def add_child(child)
        @children << child
      end

      # Render the node to an HTML string
      #
      # @return [String] the rendered HTML
      def to_html
        if void_element?
          "<#{tag}#{render_attributes}>"
        elsif children.empty?
          "<#{tag}#{render_attributes}></#{tag}>"
        else
          inner = children.map { |c| c.is_a?(Node) ? c.to_html : Escape.html(c.to_s) }.join
          "<#{tag}#{render_attributes}>#{inner}</#{tag}>"
        end
      end

      private

      VOID_ELEMENTS = %i[area base br col embed hr img input link meta param source track wbr].freeze

      # @return [Boolean] true if this is a void (self-closing) element
      def void_element?
        VOID_ELEMENTS.include?(tag)
      end

      # @return [String] rendered attribute string
      def render_attributes
        return '' if attributes.empty?

        attrs = attributes.map do |key, value|
          if value == true
            " #{key}"
          elsif value == false || value.nil?
            ''
          else
            " #{key}=\"#{Escape.html(value)}\""
          end
        end.join

        attrs
      end
    end
  end
end
