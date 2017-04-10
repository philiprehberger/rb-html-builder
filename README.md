# philiprehberger-html_builder

[![Tests](https://github.com/philiprehberger/rb-html-builder/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-html-builder/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-html_builder.svg)](https://rubygems.org/gems/philiprehberger-html_builder)
[![License](https://img.shields.io/github/license/philiprehberger/rb-html-builder)](LICENSE)

Programmatic HTML builder with tag DSL and auto-escaping

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-html_builder"
```

Or install directly:

```bash
gem install philiprehberger-html_builder
```

## Usage

```ruby
require "philiprehberger/html_builder"

html = Philiprehberger::HtmlBuilder.build do
  div(class: 'card') do
    h1 'Title'
    p 'Content'
  end
end
# => '<div class="card"><h1>Title</h1><p>Content</p></div>'
```

### Auto-Escaping

Text content and attribute values are automatically escaped:

```ruby
Philiprehberger::HtmlBuilder.build { p '<script>alert("xss")</script>' }
# => '<p>&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;</p>'
```

### Void Elements

Self-closing elements like `br`, `hr`, `img`, `input`, `meta`, and `link` render without closing tags:

```ruby
Philiprehberger::HtmlBuilder.build do
  img(src: 'photo.jpg', alt: 'Photo')
  br
  input(type: 'text', name: 'email')
end
# => '<img src="photo.jpg" alt="Photo"><br><input type="text" name="email">'
```

### Attributes

Pass attributes as keyword arguments to any tag:

```ruby
Philiprehberger::HtmlBuilder.build do
  a(href: '/about', class: 'nav-link') { text 'About' }
  input(type: 'checkbox', checked: true, disabled: false)
end
```

### Raw HTML

Insert pre-rendered HTML without escaping:

```ruby
Philiprehberger::HtmlBuilder.build do
  div { raw '<em>pre-rendered</em>' }
end
```

## API

| Method | Description |
|--------|-------------|
| `HtmlBuilder.build { ... }` | Build HTML using the tag DSL, returns a string |
| `Builder#to_html` | Render the builder contents to an HTML string |
| `Builder#text(content)` | Add escaped text content to the current element |
| `Builder#raw(html)` | Add raw HTML without escaping |
| `Escape.html(value)` | Escape HTML special characters in a string |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
