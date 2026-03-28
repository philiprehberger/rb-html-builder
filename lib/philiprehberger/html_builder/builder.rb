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
        @components = {}
      end

      # Render all root-level nodes to HTML (minified)
      #
      # @return [String] the rendered HTML
      def to_html
        @root_children.map { |c| c.respond_to?(:to_html) ? c.to_html : Escape.html(c.to_s) }.join
      end

      # Render all root-level nodes to pretty-printed HTML with indentation
      #
      # @param indent_size [Integer] number of spaces per indent level (default 2)
      # @return [String] the pretty-printed HTML
      def to_pretty_html(indent_size: 2)
        @root_children.map do |c|
          if c.respond_to?(:to_html)
            c.to_html(indent: 0, indent_size: indent_size)
          else
            Escape.html(c.to_s)
          end
        end.join("\n")
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

      # Conditionally render a block if the condition is truthy
      #
      # @param condition [Object] the condition to evaluate
      # @yield the block to render if condition is truthy
      # @return [void]
      def render_if(condition, &block)
        return unless condition
        raise Error, 'a block is required for render_if' unless block

        instance_eval(&block)
      end

      # Conditionally render a block if the condition is falsy
      #
      # @param condition [Object] the condition to evaluate
      # @yield the block to render if condition is falsy
      # @return [void]
      def render_unless(condition, &block)
        return if condition
        raise Error, 'a block is required for render_unless' unless block

        instance_eval(&block)
      end

      # Define a reusable named component
      #
      # @param name [Symbol, String] the component name
      # @yield the block that defines the component's HTML
      # @return [void]
      def define_component(name, &block)
        raise Error, 'a block is required for define_component' unless block

        @components[name.to_sym] = block
      end

      # Render a previously defined component
      #
      # @param name [Symbol, String] the component name
      # @param locals [Hash] local variables passed to the component block
      # @return [void]
      def use_component(name, **locals)
        block = @components[name.to_sym]
        raise Error, "undefined component: #{name}" unless block

        if block.arity.zero? || (block.arity.negative? && locals.empty?)
          instance_eval(&block)
        else
          instance_exec(locals, &block)
        end
      end

      # Form builder helper: builds a form tag with common defaults
      #
      # @param action [String] the form action URL
      # @param method_type [String] the HTTP method (default "post")
      # @param attrs [Hash] additional attributes
      # @yield the form contents
      # @return [Node]
      def form_for(action, method_type: 'post', **attrs, &block)
        form(action: action, method: method_type, **attrs, &block)
      end

      # Form builder helper: builds a label + input pair
      #
      # @param name [String, Symbol] the field name
      # @param label_text [String] the label text
      # @param type [String] the input type (default "text")
      # @param attrs [Hash] additional input attributes
      # @return [void]
      def field(name, label_text: nil, type: 'text', **attrs)
        field_id = attrs.delete(:id) || name.to_s.tr('_', '-')
        label_str = label_text || name.to_s.gsub('_', ' ').split.map(&:capitalize).join(' ')
        label label_str, for: field_id
        input(type: type, name: name.to_s, id: field_id, **attrs)
      end

      # Form builder helper: builds a label + select with options
      #
      # @param name [String, Symbol] the field name
      # @param options_list [Array<Array, String>] list of [text, value] pairs or plain strings
      # @param label_text [String] the label text
      # @param selected [String, nil] the selected value
      # @param attrs [Hash] additional select attributes
      # @return [void]
      def select_field(name, options_list, label_text: nil, selected: nil, **attrs)
        field_id = attrs.delete(:id) || name.to_s.tr('_', '-')
        label_str = label_text || name.to_s.gsub('_', ' ').split.map(&:capitalize).join(' ')
        label label_str, for: field_id
        select(name: name.to_s, id: field_id, **attrs) do
          options_list.each do |opt|
            if opt.is_a?(Array)
              opt_text, opt_value = opt
              option_attrs = { value: opt_value.to_s }
              option_attrs[:selected] = true if opt_value.to_s == selected.to_s
              option opt_text, **option_attrs
            else
              option_attrs = { value: opt.to_s }
              option_attrs[:selected] = true if opt.to_s == selected.to_s
              option opt.to_s, **option_attrs
            end
          end
        end
      end

      # Form builder helper: builds a label + textarea
      #
      # @param name [String, Symbol] the field name
      # @param content [String, nil] the textarea content
      # @param label_text [String] the label text
      # @param attrs [Hash] additional textarea attributes
      # @return [void]
      def textarea_field(name, content = nil, label_text: nil, **attrs)
        field_id = attrs.delete(:id) || name.to_s.tr('_', '-')
        label_str = label_text || name.to_s.gsub('_', ' ').split.map(&:capitalize).join(' ')
        label label_str, for: field_id
        textarea(content, name: name.to_s, id: field_id, **attrs)
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
      def to_html(indent: nil, indent_size: 2)
        if indent
          "#{' ' * (indent * indent_size)}#{@html}"
        else
          @html
        end
      end
    end
  end
end
