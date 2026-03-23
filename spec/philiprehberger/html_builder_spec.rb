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
