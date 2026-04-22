# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2026-04-16

### Added
- HTML5 `<!DOCTYPE html>` helper via `Builder#doctype` and `HtmlBuilder.document`

## [0.5.0] - 2026-04-15

### Added
- `list(items, ordered: false, **attrs, &block)` helper for building `<ul>` or `<ol>` lists from an array of items with optional custom rendering via block

## [0.4.0] - 2026-04-15

### Added
- `HtmlBuilder.escape(value)` module method for escaping arbitrary strings using the DSL's escaper

## [0.3.0] - 2026-04-14

### Added
- `hidden_field(name, value)` helper for generating hidden input elements
- `submit(text, **attrs)` helper for generating submit buttons with optional attributes
- `class_names(*args)` helper for building conditional CSS class strings from mixed arguments
- `cache(key) { }` for fragment caching with instance-level memoization

## [0.2.3] - 2026-04-08

### Changed
- Align gemspec summary with README description.

## [0.2.2] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.2.1] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.2.0] - 2026-03-28

### Added
- Form builder helpers (`form_for`, `field`, `select_field`, `textarea_field`) for streamlined form construction
- HTML5 data/aria attribute support via hash syntax (`data: { id: 1 }` renders as `data-id="1"`)
- Conditional rendering with `render_if` and `render_unless` blocks
- Component/partial system with `define_component` and `use_component` for reusable named blocks
- Pretty-printed output mode via `build_pretty` with configurable indentation
- Minified output mode via `build_minified` (alias for `build`)
- HTML fragment merging via `HtmlBuilder.merge` to combine multiple builder outputs

## [0.1.3] - 2026-03-24

### Fixed
- Remove inline comments from Development section to match template

## [0.1.2] - 2026-03-22

### Changed
- Expanded test suite to 30+ examples covering edge cases, error paths, and boundary conditions

## [0.1.1] - 2026-03-22

### Changed
- Version bump for republishing

## [0.1.0] - 2026-03-22

### Added
- Initial release
- Tag DSL with nested block syntax for building HTML
- Auto-escaping of text content and attribute values
- Void element support (br, hr, img, input, meta, link, and others)
- Attributes hash support on all elements
- Raw HTML insertion for pre-rendered content
