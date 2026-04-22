# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::HtmlBuilder do
  it 'has a version number' do
    expect(Philiprehberger::HtmlBuilder::VERSION).not_to be_nil
  end

  describe '.build' do
    it 'raises an error without a block' do
      expect { described_class.build }.to raise_error(Philiprehberger::HtmlBuilder::Error, 'a block is required')
    end

    it 'builds a simple element' do
      html = described_class.build { p 'Hello' }
      expect(html).to eq('<p>Hello</p>')
    end

    it 'builds nested elements' do
      html = described_class.build do
        div(class: 'card') do
          h1 'Title'
          p 'Content'
        end
      end
      expect(html).to eq('<div class="card"><h1>Title</h1><p>Content</p></div>')
    end

    it 'auto-escapes text content' do
      html = described_class.build { p '<script>alert("xss")</script>' }
      expect(html).to eq('<p>&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;</p>')
    end

    it 'auto-escapes attribute values' do
      html = described_class.build { div(data: 'a"b') {} }
      expect(html).to eq('<div data="a&quot;b"></div>')
    end

    it 'renders void elements without closing tags' do
      html = described_class.build do
        br
        hr
        img(src: 'photo.jpg', alt: 'Photo')
      end
      expect(html).to eq('<br><hr><img src="photo.jpg" alt="Photo">')
    end

    it 'renders input as a void element' do
      html = described_class.build { input(type: 'text', name: 'email') }
      expect(html).to eq('<input type="text" name="email">')
    end

    it 'renders meta and link as void elements' do
      html = described_class.build do
        meta(charset: 'utf-8')
        link(rel: 'stylesheet', href: 'style.css')
      end
      expect(html).to eq('<meta charset="utf-8"><link rel="stylesheet" href="style.css">')
    end

    it 'handles boolean attributes' do
      html = described_class.build { input(type: 'checkbox', checked: true, disabled: false) }
      expect(html).to eq('<input type="checkbox" checked>')
    end

    it 'handles multiple root elements' do
      html = described_class.build do
        h1 'First'
        h2 'Second'
      end
      expect(html).to eq('<h1>First</h1><h2>Second</h2>')
    end

    it 'supports deeply nested elements' do
      html = described_class.build do
        div(id: 'outer') do
          div(id: 'middle') do
            div(id: 'inner') do
              span 'deep'
            end
          end
        end
      end
      expect(html).to eq('<div id="outer"><div id="middle"><div id="inner"><span>deep</span></div></div></div>')
    end

    it 'supports text nodes via text method' do
      html = described_class.build do
        p do
          text 'Hello '
          strong 'world'
        end
      end
      expect(html).to eq('<p>Hello <strong>world</strong></p>')
    end

    it 'supports raw HTML insertion' do
      html = described_class.build do
        div do
          raw '<em>already escaped</em>'
        end
      end
      expect(html).to eq('<div><em>already escaped</em></div>')
    end

    it 'renders empty non-void elements with closing tag' do
      html = described_class.build { div {} }
      expect(html).to eq('<div></div>')
    end

    it 'builds an anchor tag with href' do
      html = described_class.build { a 'Click me', href: 'https://example.com' }
      expect(html).to eq('<a href="https://example.com">Click me</a>')
    end

    it 'builds an unordered list' do
      html = described_class.build do
        ul do
          li 'Item 1'
          li 'Item 2'
          li 'Item 3'
        end
      end
      expect(html).to eq('<ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul>')
    end

    it 'builds an ordered list' do
      html = described_class.build do
        ol do
          li 'First'
          li 'Second'
        end
      end
      expect(html).to eq('<ol><li>First</li><li>Second</li></ol>')
    end

    it 'builds a table' do
      html = described_class.build do
        table do
          tr do
            th 'Name'
            th 'Age'
          end
          tr do
            td 'Alice'
            td '30'
          end
        end
      end
      expect(html).to eq('<table><tr><th>Name</th><th>Age</th></tr><tr><td>Alice</td><td>30</td></tr></table>')
    end

    it 'builds a form with inputs' do
      html = described_class.build do
        form(action: '/submit', method: 'post') do
          label 'Name', for: 'name'
          input(type: 'text', name: 'name', id: 'name')
          button 'Submit', type: 'submit'
        end
      end
      expect(html).to include('<form action="/submit" method="post">')
      expect(html).to include('<label for="name">Name</label>')
      expect(html).to include('<input type="text" name="name" id="name">')
      expect(html).to include('<button type="submit">Submit</button>')
    end

    it 'builds heading tags h1 through h6' do
      html = described_class.build do
        h1 'One'
        h2 'Two'
        h3 'Three'
        h4 'Four'
        h5 'Five'
        h6 'Six'
      end
      expect(html).to include('<h1>One</h1>')
      expect(html).to include('<h6>Six</h6>')
    end

    it 'renders span with text content' do
      html = described_class.build { span 'inline' }
      expect(html).to eq('<span>inline</span>')
    end

    it 'renders section and article elements' do
      html = described_class.build do
        section do
          article do
            p 'Content'
          end
        end
      end
      expect(html).to eq('<section><article><p>Content</p></article></section>')
    end

    it 'renders embed as a void element' do
      html = described_class.build { embed(src: 'file.swf', type: 'application/x-shockwave-flash') }
      expect(html).to eq('<embed src="file.swf" type="application/x-shockwave-flash">')
    end

    it 'renders source as a void element' do
      html = described_class.build { source(src: 'audio.mp3', type: 'audio/mpeg') }
      expect(html).to eq('<source src="audio.mp3" type="audio/mpeg">')
    end

    it 'handles nil attribute values by omitting them' do
      html = described_class.build { div(class: nil) {} }
      expect(html).to eq('<div></div>')
    end

    it 'handles multiple attributes on the same element' do
      html = described_class.build { div(id: 'main', class: 'container', role: 'main') {} }
      expect(html).to eq('<div id="main" class="container" role="main"></div>')
    end

    it 'escapes text added via text method' do
      html = described_class.build do
        p do
          text '<dangerous>'
        end
      end
      expect(html).to eq('<p>&lt;dangerous&gt;</p>')
    end

    it 'renders an element with no attributes and no content' do
      html = described_class.build { span {} }
      expect(html).to eq('<span></span>')
    end

    it 'renders nav and footer elements' do
      html = described_class.build do
        nav { a 'Home', href: '/' }
        footer { p 'Copyright' }
      end
      expect(html).to eq('<nav><a href="/">Home</a></nav><footer><p>Copyright</p></footer>')
    end

    it 'renders header and main elements' do
      html = described_class.build do
        header { h1 'Title' }
        main { p 'Body' }
      end
      expect(html).to eq('<header><h1>Title</h1></header><main><p>Body</p></main>')
    end
  end

  describe 'data/aria attribute support' do
    it 'expands data hash into data-* attributes' do
      html = described_class.build do
        div(data: { id: 1, action: 'click' }) {}
      end
      expect(html).to eq('<div data-id="1" data-action="click"></div>')
    end

    it 'expands aria hash into aria-* attributes' do
      html = described_class.build do
        button('Menu', aria: { expanded: 'false', label: 'Toggle menu' })
      end
      expect(html).to eq('<button aria-expanded="false" aria-label="Toggle menu">Menu</button>')
    end

    it 'mixes data/aria hashes with regular attributes' do
      html = described_class.build do
        div(id: 'panel', class: 'active', data: { tab: 'home' }, aria: { hidden: 'false' }) {}
      end
      expect(html).to eq('<div id="panel" class="active" data-tab="home" aria-hidden="false"></div>')
    end

    it 'handles nested data attributes with numeric values' do
      html = described_class.build do
        span(data: { count: 42, enabled: true }) { text 'info' }
      end
      expect(html).to include('data-count="42"')
      expect(html).to include('data-enabled')
    end

    it 'handles empty data hash' do
      html = described_class.build { div(data: {}) {} }
      expect(html).to eq('<div></div>')
    end
  end

  describe 'conditional rendering' do
    it 'renders block when render_if condition is truthy' do
      html = described_class.build do
        render_if(true) { p 'visible' }
      end
      expect(html).to eq('<p>visible</p>')
    end

    it 'does not render block when render_if condition is falsy' do
      html = described_class.build do
        render_if(false) { p 'hidden' }
      end
      expect(html).to eq('')
    end

    it 'renders block when render_if condition is a truthy value' do
      html = described_class.build do
        render_if('yes') { span 'shown' }
      end
      expect(html).to eq('<span>shown</span>')
    end

    it 'does not render block when render_if condition is nil' do
      html = described_class.build do
        render_if(nil) { p 'hidden' }
      end
      expect(html).to eq('')
    end

    it 'renders block when render_unless condition is falsy' do
      html = described_class.build do
        render_unless(false) { p 'visible' }
      end
      expect(html).to eq('<p>visible</p>')
    end

    it 'does not render block when render_unless condition is truthy' do
      html = described_class.build do
        render_unless(true) { p 'hidden' }
      end
      expect(html).to eq('')
    end

    it 'renders render_unless block when condition is nil' do
      html = described_class.build do
        render_unless(nil) { p 'shown' }
      end
      expect(html).to eq('<p>shown</p>')
    end

    it 'works with conditional rendering inside nested elements' do
      show_subtitle = false
      html = described_class.build do
        div do
          h1 'Title'
          render_if(show_subtitle) { h2 'Subtitle' }
          p 'Content'
        end
      end
      expect(html).to eq('<div><h1>Title</h1><p>Content</p></div>')
    end

    it 'works with render_if containing nested elements' do
      html = described_class.build do
        render_if(true) do
          div(class: 'alert') do
            p 'Warning!'
          end
        end
      end
      expect(html).to eq('<div class="alert"><p>Warning!</p></div>')
    end
  end

  describe 'component/partial system' do
    it 'defines and uses a simple component' do
      html = described_class.build do
        define_component(:header_bar) do
          header { h1 'My Site' }
        end
        use_component(:header_bar)
      end
      expect(html).to eq('<header><h1>My Site</h1></header>')
    end

    it 'reuses a component multiple times' do
      html = described_class.build do
        define_component(:separator) { hr }
        use_component(:separator)
        p 'Content'
        use_component(:separator)
      end
      expect(html).to eq('<hr><p>Content</p><hr>')
    end

    it 'supports components with locals' do
      html = described_class.build do
        define_component(:greeting) do |locals|
          p "Hello, #{locals[:name]}!"
        end
        use_component(:greeting, name: 'Alice')
        use_component(:greeting, name: 'Bob')
      end
      expect(html).to eq('<p>Hello, Alice!</p><p>Hello, Bob!</p>')
    end

    it 'raises error for undefined component' do
      expect do
        described_class.build do
          use_component(:nonexistent)
        end
      end.to raise_error(Philiprehberger::HtmlBuilder::Error, 'undefined component: nonexistent')
    end

    it 'raises error for define_component without block' do
      expect do
        described_class.build do
          define_component(:test)
        end
      end.to raise_error(Philiprehberger::HtmlBuilder::Error, 'a block is required for define_component')
    end

    it 'uses component with string name' do
      html = described_class.build do
        define_component('footer_bar') do
          footer { p 'Footer' }
        end
        use_component('footer_bar')
      end
      expect(html).to eq('<footer><p>Footer</p></footer>')
    end

    it 'nests components inside other elements' do
      html = described_class.build do
        define_component(:card) do |locals|
          div(class: 'card') do
            h2 locals[:title]
            p locals[:body]
          end
        end
        div(class: 'container') do
          use_component(:card, title: 'Card 1', body: 'Body 1')
          use_component(:card, title: 'Card 2', body: 'Body 2')
        end
      end
      expect(html).to include('<div class="card"><h2>Card 1</h2><p>Body 1</p></div>')
      expect(html).to include('<div class="card"><h2>Card 2</h2><p>Body 2</p></div>')
    end
  end

  describe 'form builder helpers' do
    it 'builds a form with form_for' do
      html = described_class.build do
        form_for('/login') do
          input(type: 'text', name: 'username')
        end
      end
      expect(html).to eq('<form action="/login" method="post"><input type="text" name="username"></form>')
    end

    it 'builds a form with custom method' do
      html = described_class.build do
        form_for('/search', method_type: 'get', class: 'search-form') do
          input(type: 'text', name: 'q')
        end
      end
      expect(html).to include('method="get"')
      expect(html).to include('class="search-form"')
    end

    it 'builds a field with label and input' do
      html = described_class.build do
        form_for('/signup') do
          field(:email, type: 'email')
        end
      end
      expect(html).to include('<label for="email">Email</label>')
      expect(html).to include('<input type="email" name="email" id="email">')
    end

    it 'builds a field with custom label text' do
      html = described_class.build do
        field(:user_name, label_text: 'Your Name')
      end
      expect(html).to include('<label for="user-name">Your Name</label>')
      expect(html).to include('<input type="text" name="user_name" id="user-name">')
    end

    it 'builds a field with custom id' do
      html = described_class.build do
        field(:email, id: 'custom-email')
      end
      expect(html).to include('<label for="custom-email">Email</label>')
      expect(html).to include('id="custom-email"')
    end

    it 'builds a select_field with options' do
      html = described_class.build do
        select_field(:country, [%w[USA us], %w[Canada ca], %w[Mexico mx]])
      end
      expect(html).to include('<label for="country">Country</label>')
      expect(html).to include('<select name="country" id="country">')
      expect(html).to include('<option value="us">USA</option>')
      expect(html).to include('<option value="ca">Canada</option>')
    end

    it 'builds a select_field with selected value' do
      html = described_class.build do
        select_field(:color, %w[Red Green Blue], selected: 'Green')
      end
      expect(html).to include('<option value="Red">Red</option>')
      expect(html).to include('<option value="Green" selected>Green</option>')
      expect(html).to include('<option value="Blue">Blue</option>')
    end

    it 'builds a textarea_field' do
      html = described_class.build do
        textarea_field(:bio, 'My biography', rows: '5')
      end
      expect(html).to include('<label for="bio">Bio</label>')
      expect(html).to include('<textarea name="bio" id="bio" rows="5">My biography</textarea>')
    end

    it 'builds a textarea_field without content' do
      html = described_class.build do
        textarea_field(:notes)
      end
      expect(html).to include('<label for="notes">Notes</label>')
      expect(html).to include('<textarea name="notes" id="notes"></textarea>')
    end

    it 'auto-generates label from underscored name' do
      html = described_class.build do
        field(:first_name)
      end
      expect(html).to include('<label for="first-name">First Name</label>')
    end
  end

  describe '#hidden_field' do
    it 'generates a hidden input with name and value' do
      html = described_class.build { hidden_field(:token, 'abc123') }
      expect(html).to eq('<input type="hidden" name="token" value="abc123">')
    end

    it 'converts symbol name and value to strings' do
      html = described_class.build { hidden_field(:action, :update) }
      expect(html).to eq('<input type="hidden" name="action" value="update">')
    end

    it 'works inside a form' do
      html = described_class.build do
        form_for('/submit') do
          hidden_field(:csrf, 'token-value')
          field(:email, type: 'email')
        end
      end
      expect(html).to include('<input type="hidden" name="csrf" value="token-value">')
    end
  end

  describe '#submit' do
    it 'generates a submit button with default text' do
      html = described_class.build { submit }
      expect(html).to eq('<button type="submit">Submit</button>')
    end

    it 'generates a submit button with custom text' do
      html = described_class.build { submit('Save') }
      expect(html).to eq('<button type="submit">Save</button>')
    end

    it 'accepts additional attributes' do
      html = described_class.build { submit('Go', class: 'btn-primary', id: 'submit-btn') }
      expect(html).to include('type="submit"')
      expect(html).to include('class="btn-primary"')
      expect(html).to include('id="submit-btn"')
      expect(html).to include('>Go</button>')
    end

    it 'works inside a form' do
      html = described_class.build do
        form_for('/login') do
          field(:username)
          submit('Log In')
        end
      end
      expect(html).to include('<button type="submit">Log In</button>')
    end
  end

  describe '#list' do
    it 'builds an unordered list from items' do
      html = described_class.build do
        list(%w[Apple Banana Cherry])
      end
      expect(html).to eq('<ul><li>Apple</li><li>Banana</li><li>Cherry</li></ul>')
    end

    it 'builds an ordered list when ordered: true' do
      html = described_class.build do
        list(%w[First Second Third], ordered: true)
      end
      expect(html).to eq('<ol><li>First</li><li>Second</li><li>Third</li></ol>')
    end

    it 'yields each item to a block for custom rendering' do
      html = described_class.build do
        list(%w[Alice Bob]) do |name|
          strong name
        end
      end
      expect(html).to eq('<ul><li><strong>Alice</strong></li><li><strong>Bob</strong></li></ul>')
    end

    it 'passes extra attributes to the list element' do
      html = described_class.build do
        list(%w[One Two], class: 'menu', id: 'nav')
      end
      expect(html).to eq('<ul class="menu" id="nav"><li>One</li><li>Two</li></ul>')
    end

    it 'renders an empty list when items is empty' do
      html = described_class.build do
        list([])
      end
      expect(html).to eq('<ul></ul>')
    end

    it 'escapes text content in items' do
      html = described_class.build do
        list(['<script>xss</script>'])
      end
      expect(html).to eq('<ul><li>&lt;script&gt;xss&lt;/script&gt;</li></ul>')
    end
  end

  describe '#class_names' do
    it 'returns a single string class' do
      result = described_class.build do
        div(class: class_names('btn')) { text 'x' }
      end
      expect(result).to include('class="btn"')
    end

    it 'joins multiple string classes' do
      result = described_class.build do
        div(class: class_names('btn', 'large')) { text 'x' }
      end
      expect(result).to include('class="btn large"')
    end

    it 'includes hash keys with truthy values' do
      result = described_class.build do
        div(class: class_names('btn', active: true, hidden: false)) { text 'x' }
      end
      expect(result).to include('class="btn active"')
    end

    it 'excludes hash keys with nil values' do
      result = described_class.build do
        div(class: class_names('base', featured: nil)) { text 'x' }
      end
      expect(result).to include('class="base"')
    end

    it 'handles all falsy hash values' do
      result = described_class.build do
        div(class: class_names(active: false, hidden: nil)) { text 'x' }
      end
      expect(result).to include('class=""')
    end

    it 'handles mixed strings and multiple hashes' do
      result = described_class.build do
        div(class: class_names('a', 'b', x: true, y: false, z: true)) { text 'x' }
      end
      expect(result).to include('class="a b x z"')
    end
  end

  describe '#cache' do
    it 'caches rendered block output' do
      call_count = 0
      html = described_class.build do
        cache(:greeting) do
          call_count += 1
          p 'Hello'
        end
        cache(:greeting) do
          call_count += 1
          p 'Hello'
        end
      end
      expect(html).to eq('<p>Hello</p><p>Hello</p>')
      expect(call_count).to eq(1)
    end

    it 'caches different keys independently' do
      html = described_class.build do
        cache(:first) { span 'A' }
        cache(:second) { span 'B' }
      end
      expect(html).to eq('<span>A</span><span>B</span>')
    end

    it 'raises error without a block' do
      expect do
        described_class.build { cache(:key) }
      end.to raise_error(Philiprehberger::HtmlBuilder::Error, 'a block is required for cache')
    end

    it 'returns cached HTML on cache hit' do
      html = described_class.build do
        cache(:nav) do
          nav { a 'Home', href: '/' }
        end
        div { text 'Content' }
        cache(:nav) do
          nav { a 'Stale', href: '/stale' }
        end
      end
      expect(html).to include('<nav><a href="/">Home</a></nav>')
      expect(html).not_to include('Stale')
    end
  end

  describe 'output modes' do
    it 'produces minified output with build' do
      html = described_class.build do
        div do
          p 'Hello'
        end
      end
      expect(html).to eq('<div><p>Hello</p></div>')
    end

    it 'produces minified output with build_minified' do
      html = described_class.build_minified do
        div do
          p 'Hello'
        end
      end
      expect(html).to eq('<div><p>Hello</p></div>')
    end

    it 'produces pretty output with build_pretty' do
      html = described_class.build_pretty do
        div do
          p 'Hello'
        end
      end
      expected = "<div>\n  <p>Hello</p>\n</div>"
      expect(html).to eq(expected)
    end

    it 'produces pretty output with custom indent size' do
      html = described_class.build_pretty(indent_size: 4) do
        div do
          p 'Hello'
        end
      end
      expected = "<div>\n    <p>Hello</p>\n</div>"
      expect(html).to eq(expected)
    end

    it 'pretty-prints nested elements' do
      html = described_class.build_pretty do
        div(class: 'outer') do
          div(class: 'inner') do
            p 'Deep content'
          end
        end
      end
      lines = html.split("\n")
      expect(lines[0]).to eq('<div class="outer">')
      expect(lines[1]).to eq('  <div class="inner">')
      expect(lines[2]).to eq('    <p>Deep content</p>')
      expect(lines[3]).to eq('  </div>')
      expect(lines[4]).to eq('</div>')
    end

    it 'pretty-prints void elements' do
      html = described_class.build_pretty do
        div do
          br
          hr
        end
      end
      lines = html.split("\n")
      expect(lines[0]).to eq('<div>')
      expect(lines[1]).to eq('  <br>')
      expect(lines[2]).to eq('  <hr>')
      expect(lines[3]).to eq('</div>')
    end

    it 'pretty-prints multiple root elements' do
      html = described_class.build_pretty do
        h1 'Title'
        p 'Content'
      end
      expect(html).to eq("<h1>Title</h1>\n<p>Content</p>")
    end

    it 'raises error for build_pretty without block' do
      expect { described_class.build_pretty }.to raise_error(Philiprehberger::HtmlBuilder::Error, 'a block is required')
    end

    it 'pretty-prints raw nodes with indentation' do
      html = described_class.build_pretty do
        div do
          raw '<em>raw content</em>'
        end
      end
      lines = html.split("\n")
      expect(lines[1]).to eq('  <em>raw content</em>')
    end
  end

  describe '.escape' do
    it 'escapes HTML entities' do
      expect(described_class.escape('<a>&"')).to eq('&lt;a&gt;&amp;&quot;')
    end

    it 'converts non-string values to strings' do
      expect(described_class.escape(42)).to eq('42')
    end

    it 'returns empty string for empty input' do
      expect(described_class.escape('')).to eq('')
    end
  end

  describe 'HTML fragment merging' do
    it 'merges two fragments' do
      frag1 = described_class.build { h1 'Title' }
      frag2 = described_class.build { p 'Content' }
      result = described_class.merge(frag1, frag2)
      expect(result).to eq('<h1>Title</h1><p>Content</p>')
    end

    it 'merges multiple fragments' do
      parts = 3.times.map { |i| described_class.build { li "Item #{i}" } }
      result = described_class.merge(*parts)
      expect(result).to eq('<li>Item 0</li><li>Item 1</li><li>Item 2</li>')
    end

    it 'merges an array of fragments' do
      parts = [
        described_class.build { header { h1 'Top' } },
        described_class.build { main { p 'Middle' } },
        described_class.build { footer { p 'Bottom' } }
      ]
      result = described_class.merge(parts)
      expect(result).to include('<header>')
      expect(result).to include('<main>')
      expect(result).to include('<footer>')
    end

    it 'returns empty string for no fragments' do
      expect(described_class.merge).to eq('')
    end

    it 'handles single fragment' do
      frag = described_class.build { p 'solo' }
      expect(described_class.merge(frag)).to eq('<p>solo</p>')
    end

    it 'merges raw strings with build output' do
      frag = described_class.build { p 'built' }
      result = described_class.merge('<div>', frag, '</div>')
      expect(result).to eq('<div><p>built</p></div>')
    end
  end

  describe Philiprehberger::HtmlBuilder::Escape do
    it 'escapes ampersands' do
      expect(described_class.html('a&b')).to eq('a&amp;b')
    end

    it 'escapes angle brackets' do
      expect(described_class.html('<b>')).to eq('&lt;b&gt;')
    end

    it 'escapes quotes' do
      expect(described_class.html('"hello\'')).to eq('&quot;hello&#39;')
    end

    it 'handles non-string values' do
      expect(described_class.html(42)).to eq('42')
    end

    it 'returns empty string for empty input' do
      expect(described_class.html('')).to eq('')
    end

    it 'does not double-escape entities' do
      expect(described_class.html('&amp;')).to eq('&amp;amp;')
    end

    it 'handles strings with no special characters' do
      expect(described_class.html('hello world')).to eq('hello world')
    end

    it 'escapes all special characters in one string' do
      expect(described_class.html('<a href="x">&\'</a>')).to eq('&lt;a href=&quot;x&quot;&gt;&amp;&#39;&lt;/a&gt;')
    end
  end

  describe 'HTML5 doctype' do
    it 'builder.doctype produces <!DOCTYPE html>' do
      html = described_class.build { doctype }
      expect(html).to eq('<!DOCTYPE html>')
    end

    it 'builder.doctype works alongside other root elements' do
      html = described_class.build do
        doctype
        html { head { title 'T' } }
      end
      expect(html).to eq('<!DOCTYPE html><html><head><title>T</title></head></html>')
    end

    it 'builder.doctype pretty-prints on its own line' do
      html = described_class.build_pretty do
        doctype
        html { head { title 'T' } }
      end
      expected = "<!DOCTYPE html>\n<html>\n  <head>\n    <title>T</title>\n  </head>\n</html>"
      expect(html).to eq(expected)
    end

    it 'HtmlBuilder.document prefixes the doctype correctly' do
      html = described_class.document { html { head { title 'T' } } }
      expect(html).to eq("<!DOCTYPE html>\n<html><head><title>T</title></head></html>")
    end

    it 'HtmlBuilder.document does not add a hardcoded html wrapper' do
      html = described_class.document { p 'naked' }
      expect(html).to eq("<!DOCTYPE html>\n<p>naked</p>")
    end

    it 'HtmlBuilder.document supports pretty output' do
      html = described_class.document(pretty: true) do
        html do
          head { title 'T' }
        end
      end
      expected = "<!DOCTYPE html>\n<html>\n  <head>\n    <title>T</title>\n  </head>\n</html>"
      expect(html).to eq(expected)
    end

    it 'HtmlBuilder.document supports custom indent size when pretty' do
      html = described_class.document(pretty: true, indent_size: 4) do
        html { body { p 'Hi' } }
      end
      expected = "<!DOCTYPE html>\n<html>\n    <body>\n        <p>Hi</p>\n    </body>\n</html>"
      expect(html).to eq(expected)
    end

    it 'HtmlBuilder.document raises without a block' do
      expect { described_class.document }.to raise_error(Philiprehberger::HtmlBuilder::Error, 'a block is required')
    end

    it 'emits capital-letter DOCTYPE' do
      html = described_class.build { doctype }
      expect(html).to include('DOCTYPE')
      expect(html).not_to include('doctype')
    end
  end

  describe Philiprehberger::HtmlBuilder::Node do
    it 'returns tag name' do
      node = described_class.new(:div)
      expect(node.tag).to eq(:div)
    end

    it 'returns attributes' do
      node = described_class.new(:div, attributes: { class: 'main' })
      expect(node.attributes).to eq({ class: 'main' })
    end

    it 'starts with empty children' do
      node = described_class.new(:div)
      expect(node.children).to eq([])
    end

    it 'adds children' do
      node = described_class.new(:div)
      node.add_child('text')
      expect(node.children).to eq(['text'])
    end
  end
end
