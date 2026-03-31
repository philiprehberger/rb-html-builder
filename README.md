# philiprehberger-html_builder

[![Tests](https://github.com/philiprehberger/rb-html-builder/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-html-builder/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-html_builder.svg)](https://rubygems.org/gems/philiprehberger-html_builder)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-html-builder)](https://github.com/philiprehberger/rb-html-builder/commits/main)

Programmatic HTML builder with tag DSL, auto-escaping, form helpers, components, and output formatting.

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

### Data and Aria Attributes

Use hash syntax for HTML5 `data-*` and `aria-*` attributes:

```ruby
Philiprehberger::HtmlBuilder.build do
  div(data: { id: 1, action: 'click' }, aria: { label: 'Panel' }) do
    button('Toggle', aria: { expanded: 'false' })
  end
end
# => '<div data-id="1" data-action="click" aria-label="Panel"><button aria-expanded="false">Toggle</button></div>'
```

### Raw HTML

Insert pre-rendered HTML without escaping:

```ruby
Philiprehberger::HtmlBuilder.build do
  div { raw '<em>pre-rendered</em>' }
end
```

### Form Builder Helpers

Streamlined helpers for building forms with automatic label generation:

```ruby
Philiprehberger::HtmlBuilder.build do
  form_for('/signup', class: 'form') do
    field(:email, type: 'email')
    field(:first_name)
    select_field(:country, [%w[USA us], %w[Canada ca]], selected: 'us')
    textarea_field(:bio, rows: '5')
    button 'Submit', type: 'submit'
  end
end
```

The `field` helper generates a `<label>` and `<input>` pair. The `select_field` helper generates a `<label>` and `<select>` with `<option>` tags. The `textarea_field` helper generates a `<label>` and `<textarea>`. Label text is auto-generated from the field name (underscores become spaces, words are capitalized).

### Conditional Rendering

Render blocks based on conditions:

```ruby
logged_in = true
admin = false

Philiprehberger::HtmlBuilder.build do
  render_if(logged_in) { p 'Welcome back!' }
  render_unless(admin) { p 'Standard user' }
end
# => '<p>Welcome back!</p><p>Standard user</p>'
```

### Components

Define reusable named blocks and render them anywhere:

```ruby
Philiprehberger::HtmlBuilder.build do
  define_component(:card) do |locals|
    div(class: 'card') do
      h2 locals[:title]
      p locals[:body]
    end
  end

  use_component(:card, title: 'First', body: 'Content 1')
  use_component(:card, title: 'Second', body: 'Content 2')
end
```

Components without parameters use a simple block with no arguments. Components with parameters receive a hash of locals.

### Output Modes

Choose between minified and pretty-printed output:

```ruby
# Minified (default)
Philiprehberger::HtmlBuilder.build do
  div { p 'Hello' }
end
# => '<div><p>Hello</p></div>'

# Pretty-printed
Philiprehberger::HtmlBuilder.build_pretty do
  div { p 'Hello' }
end
# => "<div>\n  <p>Hello</p>\n</div>"

# Pretty-printed with custom indent
Philiprehberger::HtmlBuilder.build_pretty(indent_size: 4) do
  div { p 'Hello' }
end
```

### Fragment Merging

Combine multiple builder outputs into a single HTML string:

```ruby
header = Philiprehberger::HtmlBuilder.build { header { h1 'Title' } }
body = Philiprehberger::HtmlBuilder.build { main { p 'Content' } }
footer = Philiprehberger::HtmlBuilder.build { footer { p 'Copyright' } }

Philiprehberger::HtmlBuilder.merge(header, body, footer)
# => '<header><h1>Title</h1></header><main><p>Content</p></main><footer><p>Copyright</p></footer>'
```

## API

| Method | Description |
|--------|-------------|
| `HtmlBuilder.build { ... }` | Build minified HTML using the tag DSL, returns a string |
| `HtmlBuilder.build_pretty { ... }` | Build pretty-printed HTML with indentation |
| `HtmlBuilder.build_minified { ... }` | Alias for `build`, explicitly produces minified output |
| `HtmlBuilder.merge(*fragments)` | Merge multiple HTML fragment strings into one |
| `Builder#to_html` | Render builder contents to a minified HTML string |
| `Builder#to_pretty_html` | Render builder contents to a pretty-printed HTML string |
| `Builder#text(content)` | Add escaped text content to the current element |
| `Builder#raw(html)` | Add raw HTML without escaping |
| `Builder#render_if(condition) { ... }` | Conditionally render a block if condition is truthy |
| `Builder#render_unless(condition) { ... }` | Conditionally render a block if condition is falsy |
| `Builder#define_component(name) { ... }` | Define a reusable named block |
| `Builder#use_component(name, **locals)` | Render a previously defined component |
| `Builder#form_for(action, method_type:, **attrs) { ... }` | Build a form tag with common defaults |
| `Builder#field(name, label_text:, type:, **attrs)` | Build a label + input pair |
| `Builder#select_field(name, options, label_text:, selected:, **attrs)` | Build a label + select with options |
| `Builder#textarea_field(name, content, label_text:, **attrs)` | Build a label + textarea |
| `Escape.html(value)` | Escape HTML special characters in a string |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-html-builder)

🐛 [Report issues](https://github.com/philiprehberger/rb-html-builder/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-html-builder/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
