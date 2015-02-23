# frozen_string_literal: true

module Philiprehberger
  module HtmlBuilder
    # DSL-based HTML builder that creates a tree of nodes
    class Builder
      STANDARD_TAGS = %i[
        a abbr address article aside audio b bdi bdo blockquote body button
        canvas caption cite code colgroup data datalist dd del details dfn
        dialog div dl dt em fieldset figcaption figure footer form
        h1 h2 h3 h4 h5 h6 head header hgroup html i iframe ins kbd label
        legend li main map mark menu meter nav noscript object ol optgroup
        option output p picture pre progress q rp rt ruby s samp script
        section select slot small span strong style sub summary sup table
        tbody td template textarea tfoot th thead time title tr u ul var video
      ].freeze

      VOID_TAGS = %i[area base br col embed hr img input link meta param source track wbr].freeze

      ALL_TAGS = (STANDARD_TAGS + VOID_TAGS).freeze

      def initialize
        @root_children = []
        @stack = []
      end

      # Render all root-level nodes to HTML
      #
      # @return [String] the rendered HTML
      def to_html
        @root_children.map { |c| c.respond_to?(:to_html) ? c.to_html : Escape.html(c.to_s) }.join
      end

      ALL_TAGS.each do |tag_name|
        define_method(tag_name) do |content = nil, **attrs, &block|
          node = Node.new(tag_name, attributes: attrs)
          node.add_child(content.to_s) if content
          current_children << node

          if block
            @stack.push(node)
            instance_eval(&block)
            @stack.pop
          end

          node
        end
      end

      # Add raw text content to the current context
      #
      # @param content [String] the text content (will be escaped)
      # @return [void]
      def text(content)
        current_children << content.to_s
      end

      # Add raw HTML content without escaping
      #
      # @param html [String] the raw HTML string
      # @return [void]
      def raw(html)
        node = RawNode.new(html)
        current_children << node
      end

      private

      # @return [Array] the children array for the current context
      def current_children
        if @stack.empty?
          @root_children
        else
          @stack.last.children
        end
      end
    end

    # A node that renders raw HTML without escaping
    class RawNode
      # @param html [String] the raw HTML
      def initialize(html)
        @html = html
      end

      # @return [String] the raw HTML
      def to_html
        @html
      end
    end
  end
end
