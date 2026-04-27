# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::HtmlBuilder::Builder do
  let(:builder) { described_class.new }

  describe '#merge_attrs' do
    it 'returns an empty hash for no arguments' do
      expect(builder.merge_attrs).to eq({})
    end

    it 'returns a copy of a single hash' do
      input = { id: 'main', class: 'btn' }
      expect(builder.merge_attrs(input)).to eq({ id: 'main', class: 'btn' })
    end

    it 'does not mutate input hashes' do
      first = { class: 'a' }
      second = { class: 'b' }
      builder.merge_attrs(first, second)
      expect(first).to eq({ class: 'a' })
      expect(second).to eq({ class: 'b' })
    end

    it 'merges unrelated keys with last-write-wins semantics' do
      result = builder.merge_attrs({ id: 'first', role: 'main' }, { id: 'second' })
      expect(result).to eq({ id: 'second', role: 'main' })
    end

    it 'concatenates class values with a single space' do
      result = builder.merge_attrs({ class: 'btn' }, { class: 'btn-large' })
      expect(result).to eq({ class: 'btn btn-large' })
    end

    it 'concatenates class values across more than two hashes' do
      result = builder.merge_attrs({ class: 'a' }, { class: 'b' }, { class: 'c' })
      expect(result).to eq({ class: 'a b c' })
    end

    it 'concatenates style values with a semicolon and space' do
      result = builder.merge_attrs({ style: 'color: red' }, { style: 'font-size: 12px' })
      expect(result).to eq({ style: 'color: red; font-size: 12px' })
    end

    it 'concatenates style values across more than two hashes' do
      result = builder.merge_attrs(
        { style: 'color: red' },
        { style: 'font-size: 12px' },
        { style: 'margin: 0' }
      )
      expect(result).to eq({ style: 'color: red; font-size: 12px; margin: 0' })
    end

    it 'merges multiple hashes with mixed keys' do
      result = builder.merge_attrs(
        { id: 'panel', class: 'card' },
        { class: 'active', style: 'color: red' },
        { style: 'font-weight: bold', role: 'main' }
      )
      expect(result).to eq({
                             id: 'panel',
                             class: 'card active',
                             style: 'color: red; font-weight: bold',
                             role: 'main'
                           })
    end

    it 'does not concatenate keys other than class and style' do
      result = builder.merge_attrs({ id: 'first' }, { id: 'second' })
      expect(result).to eq({ id: 'second' })
    end

    it 'keeps the first class value when later hashes lack the key' do
      result = builder.merge_attrs({ class: 'btn' }, { id: 'main' })
      expect(result).to eq({ class: 'btn', id: 'main' })
    end

    it 'keeps the later class value when earlier hashes lack the key' do
      result = builder.merge_attrs({ id: 'main' }, { class: 'btn' })
      expect(result).to eq({ id: 'main', class: 'btn' })
    end

    it 'ignores nil hashes' do
      result = builder.merge_attrs({ class: 'btn' }, nil, { class: 'large' })
      expect(result).to eq({ class: 'btn large' })
    end
  end

  describe '#aria' do
    it 'returns an empty hash when no pairs are given' do
      expect(builder.aria).to eq({})
    end

    it 'converts a single snake_case key to aria-kebab-case' do
      expect(builder.aria(label: 'menu')).to eq({ 'aria-label' => 'menu' })
    end

    it 'converts boolean values to their string form' do
      expect(builder.aria(label: 'menu', expanded: false)).to eq({
                                                                   'aria-label' => 'menu',
                                                                   'aria-expanded' => 'false'
                                                                 })
    end

    it 'converts true boolean values to "true"' do
      expect(builder.aria(hidden: true)).to eq({ 'aria-hidden' => 'true' })
    end

    it 'converts numeric values to strings' do
      expect(builder.aria(level: 2)).to eq({ 'aria-level' => '2' })
    end

    it 'converts multi-word snake_case keys to hyphenated aria attributes' do
      expect(builder.aria(labelled_by: 'header-id')).to eq({ 'aria-labelled-by' => 'header-id' })
    end

    it 'omits keys with nil values from the result' do
      expect(builder.aria(label: 'menu', describedby: nil)).to eq({ 'aria-label' => 'menu' })
    end

    it 'returns an empty hash when all values are nil' do
      expect(builder.aria(label: nil, expanded: nil)).to eq({})
    end

    it 'handles many pairs at once' do
      result = builder.aria(label: 'menu', expanded: true, controls: 'submenu', hidden: false)
      expect(result).to eq({
                             'aria-label' => 'menu',
                             'aria-expanded' => 'true',
                             'aria-controls' => 'submenu',
                             'aria-hidden' => 'false'
                           })
    end
  end
end
