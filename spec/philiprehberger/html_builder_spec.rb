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
  end
end
