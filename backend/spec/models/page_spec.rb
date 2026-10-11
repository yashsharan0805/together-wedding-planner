# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Page do
  describe 'serialization and deserialization' do
    let(:page) { build(:page, slug: '', title: 'Home', content: '# Foobar', subtitle: 'hey hey!') }

    it 'preserves the attributes after persisting and reading from the database' do
      wedding = create(:wedding)
      website = wedding.website
      website.update!(pages: [page])

      expect(website.reload.pages.first.attributes).to eq(
        slug: '',
        title: 'Home',
        content: '# Foobar',
        subtitle: 'hey hey!',
        title_font_family: 'Monsieur La Doulaise'
      )
    end
  end

  describe 'validations' do
    let(:subject) { build(:page) }

    it { is_expected.to be_valid }

    describe 'slug' do
      it { is_expected.to allow_value('').for(:slug) }
      it { is_expected.to allow_value('foo').for(:slug) }
      it { is_expected.to allow_value('foo1').for(:slug) }
      it { is_expected.to allow_value('foo-1').for(:slug) }
      it { is_expected.to allow_value('1').for(:slug) }
      it { is_expected.to allow_value('foo/bar').for(:slug) }
      it { is_expected.to allow_value('foo-bar').for(:slug) }

      it { is_expected.not_to allow_value(nil).for(:slug) }
      it { is_expected.not_to allow_value('/').for(:slug) }
      it { is_expected.not_to allow_value(' ').for(:slug) }
      it { is_expected.not_to allow_value('/foo').for(:slug) }
      it { is_expected.not_to allow_value('foo.1').for(:slug) }
      it { is_expected.not_to allow_value('Foo').for(:slug) }
      it { is_expected.not_to allow_value('foo bar').for(:slug) }
      it { is_expected.not_to allow_value('invitation').for(:slug) } # reserved
      it { is_expected.not_to allow_value(:invitation).for(:slug) } # reserved
    end

    describe 'title' do
      it { is_expected.to validate_presence_of(:title) }
    end

    describe 'title font family' do
      it { is_expected.to validate_presence_of(:title_font_family) }
      it { is_expected.to validate_inclusion_of(:title_font_family).in_array(FONTS_AVAILABLE) }
    end
  end
end
