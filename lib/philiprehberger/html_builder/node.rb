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
      # @param indent [Integer, nil] current indentation level (nil for minified)
      # @param indent_size [Integer] number of spaces per indent level
      # @return [String] the rendered HTML
      def to_html(indent: nil, indent_size: 2)
        flat_attrs = flatten_attributes(attributes)

        if indent
          render_pretty(flat_attrs, indent: indent, indent_size: indent_size)
        else
          render_inline(flat_attrs)
        end
      end

      private

      VOID_ELEMENTS = %i[area base br col embed hr img input link meta param source track wbr].freeze

      # @return [Boolean] true if this is a void (self-closing) element
      def void_element?
        VOID_ELEMENTS.include?(tag)
      end

      # Flatten nested hash attributes (data, aria) into hyphenated keys
      #
      # @param attrs [Hash] the attributes hash
      # @return [Hash] flattened attributes
      def flatten_attributes(attrs)
        result = {}
        attrs.each do |key, value|
          if value.is_a?(Hash)
            value.each do |sub_key, sub_value|
              result[:"#{key}-#{sub_key}"] = sub_value
            end
          else
            result[key] = value
          end
        end
        result
      end

      # Render a single attribute pair
      #
      # @param key [Symbol] attribute name
      # @param value [Object] attribute value
      # @return [String] rendered attribute string
      def render_attribute(key, value)
        if value == true
          " #{key}"
        elsif value == false || value.nil?
          ''
        else
          " #{key}=\"#{Escape.html(value)}\""
        end
      end

      # @return [String] rendered attribute string
      def render_attributes(attrs)
        return '' if attrs.empty?

        attrs.map { |key, value| render_attribute(key, value) }.join
      end

      # Render inline (minified) HTML
      def render_inline(flat_attrs)
        attr_str = render_attributes(flat_attrs)
        if void_element?
          "<#{tag}#{attr_str}>"
        elsif children.empty?
          "<#{tag}#{attr_str}></#{tag}>"
        else
          inner = children.map { |c| c.respond_to?(:to_html) ? c.to_html : Escape.html(c.to_s) }.join
          "<#{tag}#{attr_str}>#{inner}</#{tag}>"
        end
      end

      # Render pretty-printed HTML with indentation
      def render_pretty(flat_attrs, indent:, indent_size:)
        attr_str = render_attributes(flat_attrs)
        pad = ' ' * (indent * indent_size)

        if void_element?
          "#{pad}<#{tag}#{attr_str}>"
        elsif children.empty?
          "#{pad}<#{tag}#{attr_str}></#{tag}>"
        else
          # Check if all children are text-only (no Node children)
          all_text = children.none? { |c| c.respond_to?(:to_html) }
          if all_text
            inner = children.map { |c| Escape.html(c.to_s) }.join
            "#{pad}<#{tag}#{attr_str}>#{inner}</#{tag}>"
          else
            lines = ["#{pad}<#{tag}#{attr_str}>"]
            children.each do |c|
              lines << if c.respond_to?(:to_html)
                         c.to_html(indent: indent + 1, indent_size: indent_size)
                       else
                         "#{' ' * ((indent + 1) * indent_size)}#{Escape.html(c.to_s)}"
                       end
            end
            lines << "#{pad}</#{tag}>"
            lines.join("\n")
          end
        end
      end
    end
  end
end
